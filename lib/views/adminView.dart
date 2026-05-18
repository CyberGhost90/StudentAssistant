import 'package:flutter/material.dart';
import 'package:student_assistant/feature/auth/auth_service.dart';
import 'package:student_assistant/routes/routemanager.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  //auth service
  final AuthService _authService = AuthService();

  //logout function
  void _logout() async {
    await _authService.signOut();
    // Navigate to login screen after logout
    Navigator.pushReplacementNamed(context, RouteManager.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home Page'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      // Placeholder content for the admin home page-KING
      body: const Center(child: Text('Welcome to the Admin Home Page!')),
    );
  }
}
