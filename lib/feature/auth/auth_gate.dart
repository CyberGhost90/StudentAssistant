import 'package:flutter/material.dart';
import 'package:student_assistant/routes/route_manager.dart';
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
          final email=session.user.email ?? '';
          WidgetsBinding.instance.addPostFrameCallback((_){
            if(email.contains('@stud.cut.ac.za'))
            {
              Navigator.pushReplacementNamed(context, RouteManager.studHome);
            }else if (email.contains('@cut.ac.za'))
            {
              Navigator.pushReplacementNamed(context, RouteManager.adminHome);
            }else{
              Navigator.pushReplacementNamed(context, RouteManager.login);
            }
          }); 
          }else{
            WidgetsBinding.instance.addPostFrameCallback((_)
            {
              Navigator.pushReplacementNamed(context, RouteManager.login);
            });
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(),),
          );
          
      }
    );
  }
}
