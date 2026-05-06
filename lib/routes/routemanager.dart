import 'package:flutter/material.dart';
import 'package:student_assistant/main.dart';

class RouteManager {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String studHome = '/studHome';
  static const String adminHome = '/adminHome';
  static const String register = '/register';
  static const String applicationForm = '/applicationForm';
  static const String profile = '/profile';
  static const String logout = '/logout';

  static Route<dynamic> GenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => const MainApp());
      //To be implemented: SplashScreen() after creating the splash screen widget
      //MaterialPageRoute(builder: (_) => const SplashScreen());
      case studHome:
        return MaterialPageRoute(builder: (context) => const MainApp());

      //To be implemented: HomeScreen() after creating the home screen widget
      //MaterialPageRoute(builder: (_) => const HomeScreen());
      case applicationForm:
        return MaterialPageRoute(builder: (context) => const MainApp());
      //To be implemented: ApplicationFormScreen() after creating the application form screen widget
      //MaterialPageRoute(builder: (_) => const ApplicationFormScreen());
      case profile:
        return MaterialPageRoute(builder: (context) => const MainApp());
      //To be implemented: ProfileScreen() after creating the profile screen widget
      //MaterialPageRoute(builder: (_) => const ProfileScreen());
      case logout:
        return MaterialPageRoute(builder: (context) => const MainApp());
      //To be implemented: LogoutScreen() after creating the logout screen widget
      //MaterialPageRoute(builder: (_) => const LogoutScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
