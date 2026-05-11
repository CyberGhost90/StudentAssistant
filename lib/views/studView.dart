import 'package:flutter/material.dart';
import 'package:student_assistant/feature/auth/auth_service.dart';
import 'package:student_assistant/routes/routemanager.dart';
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

    Future.microtask(() {
      context.read<StudentViewModel>().loadStudentData();
    });
  }

  Future<void> refreshData() async {
    await context.read<StudentViewModel>().loadStudentData();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<StudentViewModel>(
      builder: (context, sm, child) {

        return Scaffold(
          backgroundColor: AppColors.blue,
          // FLOATING ACTION BUTTON
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.blueGrey,
            onPressed: () {
              Navigator.pushNamed(context, '/apply');
            },
            icon: const Icon(Icons.add),
            label: const Text("Apply"),
          ),

          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.blueGrey,

            title: const Text(
              "Student Dashboard",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            actions: [

              // LOGOUT BUTTON
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
              ? const Center(
                  child: CircularProgressIndicator(),
                )

              : RefreshIndicator(

                  onRefresh: refreshData,

                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),

                    padding: const EdgeInsets.all(16),
                     children: [

                        // WELCOME CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),

                            gradient: const LinearGradient(
                              colors: [
                                AppColors.blue,
                                AppColors.blueGrey,
                              ],

                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [

                                  const CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.white,

                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                      size: 30,
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),

                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),

                                    child: const Text(
                                      "Student Portal",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "Welcome ${sm.firstName}",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                sm.studentName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

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
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,

                          children: [

                            const Text(
                              "My Applications",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),

                                borderRadius: BorderRadius.circular(20),
                              ),

                              child:Text(
                                "${sm.applications.length} Total",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),

                                child: Column(
                                  children: [

                                    Icon(
                                      Icons.inbox,
                                      size: 70,
                                      color: Colors.grey.shade400,
                                    ),

                                    const SizedBox(height: 16),

                                    const Text(
                                      "No Applications Yet",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    const Text(
                                      "Start applying for available Student Assistant positions.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )

                            : ListView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),

                                itemCount: sm.applications.length,

                                itemBuilder: (context, index) {

                                  final application =
                                      sm.applications[index];

                                  return ApplicationCard(
                                    application: application,
                                  );
                                },
                              ),

                        const SizedBox(height: 30),

                        // AVAILABLE APPLICATIONS TITLE
                        const Text(
                          "Available Applications",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // MODULE LIST
                        vm.modules.isEmpty

                             const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    "No available modules currently.",
                                  ),
                                ),
                              )
                  ]
                  )
              )
        )
    
  }
  );
  }
}

//                             

