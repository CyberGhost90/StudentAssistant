import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentViewModel extends ChangeNotifier {
  final SupabaseClient _supabaseClient;

  StudentViewModel(this._supabaseClient);

  // Form fields
  int? _yearOfStudy;
  String? _module1;
  String? _module2;
  File? _supportingDocument;
  bool _eligibilityConfirmed = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters for form fields
  int? get yearOfStudy => _yearOfStudy;
  String? get module1 => _module1;
  String? get module2 => _module2;
  File? get supportingDocument => _supportingDocument;
  bool get eligibilityConfirmed => _eligibilityConfirmed;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters for form fields
  void setYearOfStudy(int? year) {
    _yearOfStudy = year;
    notifyListeners();
  }

  void setModule1(String? module) {
    _module1 = module;
    notifyListeners();
  }

  void setModule2(String? module) {
    _module2 = module;
    notifyListeners();
  }

  void setSupportingDocument(File? file) {
    _supportingDocument = file;
    notifyListeners();
  }

  void setEligibilityConfirmed(bool confirmed) {
    _eligibilityConfirmed = confirmed;
    notifyListeners();
  }

  // Validation logic
  String? validateYearOfStudy(int? year) {
    if (year == null) {
      return 'Please select your year of study.';
    }
    return null;
  }

  String? validateModule1(String? module) {
    if (module == null || module.isEmpty) {
      return 'Please select your first module.';
    }
    return null;
  }

  String? validateEligibility(bool? confirmed) {
    if (confirmed == null || !confirmed) {
      return 'You must confirm eligibility.';
    }
    return null;
  }

  // Method to handle document upload to Supabase Storage
  Future<String?> _uploadDocument() async {
    if (_supportingDocument == null) return null;

    try {
      final String path = await _supabaseClient.storage
          .from('supporting_documents')
          .upload(
            '${_supabaseClient.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.pdf',
            _supportingDocument!,
            fileOptions: const FileOptions(upsert: true),
          );
      return _supabaseClient.storage
          .from('supporting_documents')
          .getPublicUrl(path);
    } on StorageException catch (e) {
      _errorMessage = 'Document upload failed: ${e.message}';
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during document upload: $e';
      notifyListeners();
      return null;
    }
  }

  // Method to submit the application
  Future<bool> submitApplication() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Basic validation before submission
    if (_yearOfStudy == null || _module1 == null || !_eligibilityConfirmed) {
      _errorMessage =
          'Please fill in all required fields and confirm eligibility.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        _errorMessage = 'User not authenticated.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if the user has already submitted an application
      //this will give an error,check columns and database before - KING
      final existingApplications = await _supabaseClient
          .from('student_applications')
          .select('id')
          .eq('student_id', userId)
          .limit(1);

      if (existingApplications.isNotEmpty) {
        _errorMessage = 'You have already submitted an application.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final documentUrl = await _uploadDocument();
      if (_supportingDocument != null && documentUrl == null) {
        _isLoading = false;
        notifyListeners();
        return false; // Upload failed
      }

      final applicationData = {
        'student_id': userId,
        'year_of_study': _yearOfStudy,
        'module_1': _module1,
        'module_2': _module2,
        'supporting_document_url': documentUrl,
        'eligibility_confirmed': _eligibilityConfirmed,
        'submission_date': DateTime.now().toIso8601String(),
      };

      await _supabaseClient
          .from('student_applications')
          .insert(applicationData);

      _isLoading = false;
      notifyListeners();
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = 'Submission failed: ${e.message}';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
