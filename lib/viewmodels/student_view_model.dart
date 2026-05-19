import 'dart:io';
import 'package:flutter/material.dart';
import 'package:student_assistant/feature/auth/auth_service.dart';
import 'package:student_assistant/models/exceptionError.dart';
import 'package:student_assistant/models/repository.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:student_assistant/routes/routemanager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentViewModel extends ChangeNotifier {
  final Repository _repository = Repository();
  final AuthService _authService = AuthService();
  Student _student = Student(
    studentEmail: "",
    firstName: "",
    surname: "",
    yearOfStudy: DateTime.now(),
    firstModule: "",
    secondModule: "",
    photoUrl: "",
    status: "",
  );
  // Form fields
  File? _supportingDocument;
  bool _eligibilityConfirmed = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters for form fields
  DateTime? get yearOfStudy => _student.yearOfStudy;
  String? get module1 => _student.firstModule;
  String? get module2 => _student.secondModule;
  File? get supportingDocument => _student.photoUrl as File?;
  bool get eligibilityConfirmed => _eligibilityConfirmed;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Setters for form fields
  void setYearOfStudy(DateTime? year) {
    _student = _student.copyWith(yearOfStudy: year);
    notifyListeners();
  }

  void setModule1(String? module) {
    _student = _student.copyWith(firstModule: module);
    notifyListeners();
  }

  void setModule2(String? module) {
    _student = _student.copyWith(secondModule: module);
    notifyListeners();
  }

  void setSupportingDocument(File? file) {
    _student = _student.copyWith(photoUrl: file?.path);
    _supportingDocument = file;
    notifyListeners();
  }

  void setEligibilityConfirmed(bool confirmed) {
    _eligibilityConfirmed = confirmed;
    _student = _student.copyWith(
      status: confirmed ? "Eligible" : "Not Eligible",
    );
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
      return _repository.uploadStudentDocs(
        _student.studentEmail!,
        _repository.pickStudentDocs() as File,
      );
    } catch (e) {
      Exceptionerror.snackBarError('Document upload failed: ${e.toString()}');
      notifyListeners();
      return null;
    }
  }

  // Method to submit the application
  Future<bool> submitApplication() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      // Basic validation before submission
      if (_student.yearOfStudy == null ||
          _student.firstModule == null ||
          !_eligibilityConfirmed) {
        _errorMessage =
            'Please fill in all required fields and confirm eligibility.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // Check if the user has already submitted an application
      //this will give an error,check columns and database before - KING
      final existingApplications = await _repository.getStudent(_student);

      if (existingApplications?.studentEmail != null) {
        _errorMessage = 'You have already submitted an application.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      //Upload document via Repository if one was picked
      if (_supportingDocument != null) {
        _student.photoUrl = await _repository.uploadStudentDocs(
          _student.studentEmail!,
          _repository.pickStudentDocs() as File,
        );
      }
      if (_student.photoUrl == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      //Create via Repository
      final success = await _repository.createStudent(_student);
      if (success != null) {
        return true;
      }
      return false;
    } catch (e) {
      Exceptionerror.alertDialogError(
        'An unexpected error occurred: $e.toString()',
      );
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
      if (_supportingDocument != null && userId != null) {
        _student.photoUrl = await _repository.uploadStudentDocs(
          userId,
          _supportingDocument!,
        );
      }

      //Update via Repository
      final success = await _repository.updateStudent(_student);
      notifyListeners();
      return success;
    } catch (e) {
      Exceptionerror.alertDialogError(
        'An unexpected error occurred: $e.toString()',
      );
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
    _supportingDocument = null;
    _eligibilityConfirmed = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> pickDocument() async {
    final fileUrl = await _repository.uploadStudentDocs(
      _student.studentEmail!,
      _repository.pickStudentDocs() as File,
    );

    if (fileUrl != null) {
      _student.photoUrl = fileUrl;
      _supportingDocument = fileUrl as File?;
      notifyListeners();
    }
  }
}
