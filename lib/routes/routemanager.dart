import 'package:flutter/material.dart';
import 'package:student_assistant/feature/auth/auth_gate.dart';
import 'package:student_assistant/feature/pages/login.dart';
import 'package:student_assistant/feature/pages/register.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:student_assistant/views/studview.dart';
import 'package:student_assistant/views/application_form_screen.dart';
import 'package:student_assistant/views/application_detail_screen.dart';
import 'package:student_assistant/views/adminView.dart';

//PLEASE DO NOT EDIT THIS PAGE
class RouteManager {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String studHome = '/studHome';
  static const String adminHome = '/adminHome';
  static const String applicationForm = '/applicationForm';
  static const String applicationDetail = '/applicationDetail';
  static const String editApplication = '/editApplication';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const AuthGate());

      case login:
        return MaterialPageRoute(builder: (_) => const Login());

      case register:
        return MaterialPageRoute(builder: (_) => const Register());

      case studHome:
        return MaterialPageRoute(builder: (_) => const Studview());

      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomePage());

      case applicationForm:
        return MaterialPageRoute(builder: (_) => const ApplicationFormScreen());

      case applicationDetail:
        final app = settings.arguments as Student;
        return MaterialPageRoute(
          builder: (_) => ApplicationDetailScreen(application: app),
        );

      case editApplication:
        return MaterialPageRoute(builder: (_) => ApplicationFormScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
