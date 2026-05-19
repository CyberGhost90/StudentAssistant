import 'package:flutter/material.dart';
import 'package:student_assistant/models/exceptionError.dart';
import 'package:student_assistant/models/repository.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:student_assistant/models/application_model.dart';

class AdminViewModel extends ChangeNotifier {
  final Repository _repository = Repository();
  final Student _student = Student(
    studentEmail: "",
    firstName: "",
    surname: "",
    firstModule: "",
    secondModule: "",
    status: "",
    yearOfStudy: DateTime.now(),
  );
  // ─── State ────────────────────────────────────────────────────────────────

  List<ApplicationModel> _applications = [];
  List<ApplicationModel> _filteredApplications = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Filter state: 'all', 'pending', 'approved', 'rejected'
  String _statusFilter = 'all';

  // ─── Getters ──────────────────────────────────────────────────────────────

  List<ApplicationModel> get applications => _filteredApplications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get statusFilter => _statusFilter;

  // Convenience counts for the dashboard
  int get totalCount => _applications.length;
  int get pendingCount =>
      _applications.where((a) => a.status == 'pending').length;
  int get approvedCount =>
      _applications.where((a) => a.status == 'approved').length;
  int get rejectedCount =>
      _applications.where((a) => a.status == 'rejected').length;

  // ─── Helpers ──────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSuccess(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// [_filteredApplications].
  void _applyFilter() {
    _filteredApplications = _statusFilter == 'all'
        ? List.from(_applications)
        : _applications.where((a) => a.status == _statusFilter).toList();
    notifyListeners();
  }

  // ─── Filter ───────────────────────────────────────────────────────────────

  /// Change the active status filter and refresh the visible list.
  void setStatusFilter(String filter) {
    _statusFilter = filter.toLowerCase();
    _applyFilter();
  }

  // ─── READ ─────────────────────────────────────────────────────────────────

  /// Fetch all student applications from Supabase, ordered newest first.
  Future<void> fetchAllApplications() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _repository.getStudents();
      _applications = (response as List)
          .map((e) => ApplicationModel.fromJson(e))
          .toList();
      _applyFilter();
    } catch (e) {
      Exceptionerror.snackBarError(
        'Failed to load applications: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  /// Update the status of an application to newStatus.
  /// newStatus must be one of: 'pending', 'approved', 'rejected'.
  Future<bool> updateApplicationStatus(
    String applicationId,
    String newStatus,
  ) async {
    assert(
      ['pending', 'approved', 'rejected'].contains(newStatus),
      'Invalid status value: $newStatus',
    );
    _student.status = newStatus; // Update the student's status before saving
    _setLoading(true);

    try {
      await _repository.updateStudent(_student);
      // Update locally so the UI reflects the change without a full reload.
      final index = _applications.indexWhere((a) => a.id == applicationId);
      if (index != -1) {
        _applications[index] = _applications[index].copyWith(status: newStatus);
        _applyFilter();
      }

      _setSuccess(
        'Application ${newStatus == 'approved'
            ? 'approved'
            : newStatus == 'rejected'
            ? 'rejected'
            : 'updated'} successfully.',
      );
      return true;
    } catch (e) {
      Exceptionerror.snackBarError(
        'Failed to update application: ${e.toString()}',
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> approveApplication(String applicationId) =>
      updateApplicationStatus(applicationId, 'approved');

  Future<bool> rejectApplication(String applicationId) =>
      updateApplicationStatus(applicationId, 'rejected');

  // ─── DELETE

  Future<bool> deleteApplication(String applicationId) async {
    _setLoading(true);

    try {
      bool success = await _repository.deleteStudent(_student);
      if (success) {
        _applications.removeWhere((a) => a.id == applicationId);
        _applyFilter();

        _setSuccess('Application removed successfully.');
        return true;
      }
      return false;
    } catch (e) {
      Exceptionerror.snackBarError(
        'Failed to delete application: ${e.toString()}',
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Shows a confirmation AlertDialog] before performing a destructive action.
  /// Returns `true` if the user confirmed, `false` otherwise.
  Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmLabel = 'Confirm',
    Color confirmColor = Colors.red,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: confirmColor),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
