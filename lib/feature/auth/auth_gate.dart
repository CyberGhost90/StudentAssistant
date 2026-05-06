import 'package:flutter/material.dart';
import 'package:student_assistant/routes/routemanager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,

      builder: (context, snapshot) {
        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        //check current session
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          if (session.user.email!.contains('@stud.cut.ac.za')) {
            return RouteManager.studHome as Widget;
          } else if (session.user.email!.contains('@cut.ac.za')) {
            return RouteManager.adminHome as Widget;
          }
        } else {
          return RouteManager.login as Widget;
        }
        return RouteManager.login as Widget;
      },
    );
  }
}
