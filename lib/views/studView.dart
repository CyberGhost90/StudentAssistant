import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          backgroundColor: Colors.blue,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.blueGrey,
            onPressed: () {
              Navigator.pushNamed(context, '/apply');
            },
            icon: const Icon(Icons.add),
            label: const Text("Apply"),
          ),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.blueGrey,
            title: const Text(
              "Student Dashboard",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await sm.logout(context);
                },
                icon: const Icon(Icons.logout),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: sm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column( // Added missing Column widget
                      children: [
                        // WELCOME CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.blueGrey],
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
                                    child: Icon(Icons.person, color: Colors.blue, size: 30),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
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
                                style: const TextStyle(color: Colors.white70, fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Manage your Student Assistant applications easily.",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // APPLICATION SECTION HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "My Applications",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${sm.applications.length} Total",
                                style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // APPLICATION LIST
                        sm.applications.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.inbox, size: 70, color: Colors.grey.shade400),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "No Applications Yet",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Start applying for available Student Assistant positions.",
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
                                  final application = sm.applications[index];
                                  // Ensure ApplicationCard is defined elsewhere
                                  return ListTile(title: Text("App ID: ${application.id}")); 
                                },
                              ),
                        const SizedBox(height: 30),
                        const Text(
                          "Available Applications",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        sm.modules.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text("No available modules currently."),
                                ),
                              )
                            : const SizedBox.shrink(), // Add logic for modules here
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}