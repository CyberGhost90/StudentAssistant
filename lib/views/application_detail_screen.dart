import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:student_assistant/routes/route_manager.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final ApplicationModel application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isDeleting = false;

  // Returns a colour and label based on application status
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.hourglass_top;
    }
  }

  // DELETE operation — only allowed while status is pending
  Future<void> _deleteApplication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete your application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await _supabase
          .from('student_applications')
          .delete()
          .eq('id', widget.application.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        // Go back to the home screen after deletion
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteManager.studHome,
          (route) => false,
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // Navigate to edit screen — only allowed while status is pending
  void _editApplication() {
    Navigator.pushNamed(
      context,
      RouteManager.editApplication,
      arguments: widget.application,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final isPending = app.status.toLowerCase() == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Banner ──────────────────────────────────────
            Card(
              color: _statusColor(app.status).withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: _statusColor(app.status), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      _statusIcon(app.status),
                      color: _statusColor(app.status),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Application Status',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          app.status[0].toUpperCase() +
                              app.status.substring(1),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _statusColor(app.status),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Application Details Card ───────────────────────────
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application Information',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: Colors.indigo),
                    ),
                    const Divider(height: 24),

                    _DetailRow(
                      icon: Icons.school,
                      label: 'Year of Study',
                      value: 'Year ${app.yearOfStudy}',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.book,
                      label: 'Module 1',
                      value: app.module1,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.book_outlined,
                      label: 'Module 2',
                      value: app.module2 ?? 'Not selected',
                      valueColor:
                          app.module2 == null ? Colors.grey : Colors.black87,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.verified_user,
                      label: 'Eligibility Confirmed',
                      value: app.eligibilityConfirmed ? 'Yes' : 'No',
                      valueColor: app.eligibilityConfirmed
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Submission Date',
                      value: _formatDate(app.submissionDate),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Supporting Document Card ───────────────────────────
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supporting Document',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: Colors.indigo),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(
                          app.supportingDocumentUrl != null
                              ? Icons.picture_as_pdf
                              : Icons.error_outline,
                          color: app.supportingDocumentUrl != null
                              ? Colors.red.shade700
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            app.supportingDocumentUrl != null
                                ? 'Document uploaded'
                                : 'No document uploaded',
                            style: TextStyle(
                              color: app.supportingDocumentUrl != null
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Action Buttons (only shown when pending) ───────────
            if (isPending) ...[
              const Text(
                'Manage Application',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _editApplication,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        side: const BorderSide(color: Colors.indigo),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isDeleting ? null : _deleteApplication,
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.delete, color: Colors.white),
                      label: Text(
                        _isDeleting ? 'Deleting...' : 'Delete',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // If not pending, show a note that edits/deletes are locked
              Card(
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This application can no longer be edited or deleted because it has been reviewed.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }
}

// ── Reusable detail row widget ─────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.indigo),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
