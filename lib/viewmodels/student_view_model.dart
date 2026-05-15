import 'dart:io';
import 'package:flutter/material.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import '../routes/routemanager.dart';
import '../feature/auth/auth_service.dart';

class StudentViewModel extends ChangeNotifier {
  final SupabaseClient _supabaseClient;
  final AuthService _authService = AuthService();

  StudentViewModel(this._supabaseClient) {
    loadStudentData();
  }

  //Profile state
  String firstName = '';

  //Application list(for HomeScreen READ)
  List<ApplicationModel> _applications = [];
  List<ApplicationModel> get applications => _applications;

  //Available Modules(displayed on HomeScreen)
  final List<Map<String, String>> modules = [
    {'level': 'IT 1st Year', 'name': 'IT 1st Year Modules'},
    {'level': 'IT 2nd Year', 'name': 'IT 2nd Year Modules'},
    {'level': 'Computer Literacy', 'name': 'Computer Literacy Modules'},
    {'level': 'ECP', 'name': 'IT Extended Programme (ECP)'},
    {'level': 'Higher Certificate', 'name': 'Higher Certificate in IT'},
    {'level': 'Open Lab', 'name': 'Open Lab'},
  ];

  // Form fields
  int? _yearOfStudy;
  String? _module1;
  String? _module2;
  File? _supportingDocument;
  bool _eligibilityConfirmed = false;

  //Status
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

  //Load student profile + applications
  Future<void> loadStudentData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      final email = _supabaseClient.auth.currentUser?.email ?? '';

      //Derive first name from email(before the @) as a simple display name until you have profiles table
      if (email.isNotEmpty) {
        final namePart = email.split('@').first.split('.').first;
        firstName = namePart.isNotEmpty
            ? '${namePart[0].toUpperCase()}${namePart.substring(1)}'
            : 'Student';
      }
      if (userId != null) {
        final response = await _supabaseClient
            .from('student_applications')
            .select()
            .eq('student_id', userId)
            .order('submission_date', ascending: false);
        _applications = (response as List)
            .map((e) => ApplicationModel.fromJson(e))
            .toList();
      }
    } on PostgrestException catch (e) {
      _errorMessage = 'Failed to load data: ${e.message}';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to handle document upload to Supabase Storage
  Future<String?> _uploadDocument() async {
    if (_supportingDocument == null) return null;

    try {
      final userId = _supabaseClient.auth.currentUser!.id;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';

      await _supabaseClient.storage
          .from('supporting_documents')
          .upload(
            '$userId/$fileName',
            _supportingDocument!,
            fileOptions: const FileOptions(upsert: true),
          );

      return _supabaseClient.storage
          .from('supporting_documents')
          .getPublicUrl('$userId/$fileName');
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

      // Use StudentModel instead of raw Map
      final application = Student(
        studentEmail: _supabaseClient.auth.currentUser?.email,
        firstName: firstName,
        module1: _module1,
        module2: _module2,
        supportingDocumentUrl: documentUrl,
        submissionDate: DateTime.now(),
        yearOfStudy: _yearOfStudy!,
      );

      await _supabaseClient
          .from('student_applications')
          .insert(application.toJson());

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
