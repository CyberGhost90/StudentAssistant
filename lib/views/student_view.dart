import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/application_model.dart';
import '../routes/route_manager.dart';
import 'package:student_assistant/viewmodels/student_view_model.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
     super.initState();
     // Use Future.microtask to trigger data loading after the first frame
     Future.microtask(() {
       if (mounted) {
         context.read<StudentViewModel>().loadStudentData();
       }
     });
  }

  // Defined properly inside the State class
  Future<void> refreshData() async {
     await context.read<StudentViewModel>().loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentViewModel>(
      builder: (context, sm, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          floatingActionButton: sm.applications.isEmpty? FloatingActionButton.extended(
            backgroundColor: Colors.indigo,
            onPressed: () {
              Navigator.pushNamed(context,RouteManager.applicationForm);
            },
            icon: const Icon(Icons.add),
            label: const Text("Apply"),
          )
          : null,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            title: const Text("Student Dashboard",style: TextStyle(fontWeight: FontWeight.bold),),
            actions: [
              IconButton(
                onPressed: refreshData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async => await sm.logout(context),
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
              const SizedBox(width: 8)
            ],
          ),
          body: sm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column( 
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // WELCOME CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Colors.indigo, Colors.blueGrey],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.person, color: Colors.indigo, size: 30),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Student Portal",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // REMOVED 'const' here because sm.firstName is dynamic
                              Text(
                                "Welcome ${sm.firstName}",
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Manage your Student Assistant applications easily.",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        //Error message
                        if(sm.errorMessage !=null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200)
                          ),
                          child: Text(sm.errorMessage!,style: TextStyle(color: Colors.red),)
                        ),
                        // APPLICATION SECTION HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("My Applications",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text("${sm.applications.length} Total",style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // APPLICATION LIST
                        sm.applications.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                                    const SizedBox(height: 12),
                                    const Text(
                                      "No Applications Yet",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Tap the Apply button below to apply for a Student Assisstant position.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: sm.applications.length,
                                itemBuilder: (context, index) {
                                  return _ApplicationCard(application:sm.applications[index]);
                                },
                              ),
                        const SizedBox(height: 24),
                        //Available Positions
                        const Text(
                          "Available Applications",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...sm.modules.map(
                          (module)=>Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.school, color: Colors.indigo,),
                              const SizedBox(width: 12,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(module['level']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),),
                                    Text(module['name']!, style: TextStyle(color: Colors.grey[600], fontSize: 12),),
                                  ],
                                ) ,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80,),
                    ],
                  ),
                ),
              ),
           );
      },
    );
  }
}

// ─── Application Card Widget ──────────────────────────────────────────────────
class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;

  const _ApplicationCard({required this.application});

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

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(application.status);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteManager.applicationDetail,
          arguments: application,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_statusIcon(application.status), color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.module1,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (application.module2 != null)
                    Text(
                      '+ ${application.module2}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Year ${application.yearOfStudy} · ${_formatDate(application.submissionDate)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                application.status[0].toUpperCase() +
                    application.status.substring(1),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}