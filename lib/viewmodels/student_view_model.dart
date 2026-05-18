import 'dart:io';
import 'package:flutter/material.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import '../routes/route_manager.dart';
import '../feature/auth/auth_service.dart';
import '../models/repository.dart';

class StudentViewModel extends ChangeNotifier {
  final Repository _repository;
  final AuthService _authService = AuthService();

  StudentViewModel(this._repository) {
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
  Student? student;

  //Status
  bool _isLoading = false;
  String? _errorMessage;

  // Getters for form fields
  int? get yearOfStudy => _yearOfStudy;
  String? get studentID => student?.studentEmail;
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

  //Pre-fill form for editing
  void loadFromApplication(ApplicationModel app) {
    _yearOfStudy = app.yearOfStudy;
    _module1 = app.module1;
    _module2 = app.module2;
    _eligibilityConfirmed = app.eligibilityConfirmed;
    _supportingDocument = null;
    _errorMessage = null;
    notifyListeners();
  }

  //Load student profile + applications
  Future<void> loadStudentData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id;
      final email = user?.email ?? '';

      //Derive first name from email(before the @) as a simple display name until you have profiles table
      if (email.isNotEmpty) {
        final namePart = email.split('@').first.split('.').first;
        firstName = namePart.isNotEmpty
            ? '${namePart[0].toUpperCase()}${namePart.substring(1)}'
            : 'Student';
      }
      if (userId != null) {
        _applications = await _repository.getApplicationForStudent(userId);
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

  //Create
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
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        _errorMessage = 'User not authenticated.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      //Duplicate check via Repository
      if (await _repository.studentHasApplication(userId)) {
        _errorMessage = 'You have already submitted an application.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      //Upload document via Repository if one was picked
      String? documentUrl;
      if (_supportingDocument != null) {
        documentUrl = await _repository.uploadStudentDocs(
          userId,
          _supportingDocument!,
        );
      }
      if (documentUrl == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      //Create via Repository
      final success = await _repository.createApplication(
        studentId: userId,
        yearOfStudy: _yearOfStudy!,
        module1: _module1!,
        eligibilityConfirmed: eligibilityConfirmed,
        documentUrl: documentUrl,
      );
      if (success) {
        await loadStudentData();
      } else {
        _errorMessage = 'Sumission failed. Please try again.';
        _isLoading = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //UPDATE: Edit existing (pending) application
  Future<bool> updateApplication(
    String applicationId, {
    int? yearOfStudy,
    String? module1,
    String? module2,
    bool? eligibilityConfirmed,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      //uplaod new document via Repository
      String? documentUrl;
      if (_supportingDocument != null && userId != null) {
        documentUrl = await _repository.uploadStudentDocs(
          userId,
          _supportingDocument!,
        );
      }

      //Update via Repository
      final success = await _repository.updateApplication(
        applicationId: applicationId,
        yearOfStudy: yearOfStudy,
        module1: module1,
        eligibilityConfirmed: eligibilityConfirmed,
        documentUrl: documentUrl,
      );
      if (success) {
        await loadStudentData();
      } else {
        _errorMessage = 'Update failed. Please try again.';
        _isLoading = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //logout
  Future<void> logout(BuildContext context) async {
    await _authService.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, RouteManager.login);
    }
  }

  //Reset form fields(call after successful submit)
  void resetForm() {
    _yearOfStudy = null;
    _module1 = null;
    _module2 = null;
    _supportingDocument = null;
    _eligibilityConfirmed = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> pickDocument() async {
    final fileUrl = await _repository.uploadStudentDocs(
      studentID!,
      supportingDocument!,
    );
    if (fileUrl != null) {
      student?.supportingDocumentUrl = fileUrl;
      _supportingDocument = fileUrl as File?;
      notifyListeners();
    }
  }
}
