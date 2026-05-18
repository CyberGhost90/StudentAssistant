import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:student_assistant/repository.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Student application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final application = widget.application;
    final isPending = application.status?.toLowerCase() == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (isPending)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEdit(),
            ),
          if (isPending)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(application),
                  const SizedBox(height: 16),
                  _buildStatusChip(application.status ?? 'pending'),
                  const SizedBox(height: 16),
                  if (application.supportingDocumentUrl != null)
                    _buildDocumentSection(application.supportingDocumentUrl!),
                  const SizedBox(height: 24),
                  if (!isPending)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            application.status?.toLowerCase() == 'approved'
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: application.status?.toLowerCase() == 'approved'
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              application.status?.toLowerCase() == 'approved'
                                  ? 'Your application has been approved. No further changes allowed.'
                                  : 'Your application was rejected. No further changes allowed.',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(Student application) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildDetailRow('Student Email', application.studentEmail ?? 'N/A'),
            _buildDetailRow('First Name', application.firstName ?? 'N/A'),
            _buildDetailRow('Surname', application.Surname ?? 'N/A'),
            const SizedBox(height: 12),
            const Text(
              'Module Selection',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Module 1', application.module1 ?? 'Not selected'),
            _buildDetailRow('Module 2', application.module2 ?? 'Not selected'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Submission Date',
              application.submissionDate != null
                  ? '${application.submissionDate!.day}/${application.submissionDate!.month}/${application.submissionDate!.year}'
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Center(
      child: Chip(
        label: Text(
          status.toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildDocumentSection(String url) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.attach_file, color: Colors.blue),
        title: const Text('Supporting Document'),
        subtitle: Text(url.split('/').last),
        trailing: const Icon(Icons.open_in_new),
        onTap: () {
          
        },
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete this application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteApplication(),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteApplication() async {
    setState(() => _isLoading = true);

    try {
      final repository = Repository();
      await repository.deleteStudent(widget.application);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application deleted successfully')),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting application: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToEdit() {
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => EditApplicationScreen(application: widget.application),
      ),
    ).then((result) {
      if (result == true && mounted) {
        
        setState(() {});
      }
    });
  }
}