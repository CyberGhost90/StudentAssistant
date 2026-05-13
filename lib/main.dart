import 'package:flutter/material.dart';
import 'package:student_assistant/models/exceptionError.dart';
import 'package:student_assistant/routes/routemanager.dart';
import 'package:student_assistant/viewmodels/student_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  try {
    await Supabase.initialize(
      url: 'https://wjcpciamdrfxxnfbvbpg.supabase.co',
      anonKey: 'sb_publishable_iVYsr0v8swgI2HD0vER2JQ_QVkXeq5E',
    );
    runApp(const MainApp());
  } catch (e) {
    // Handle initialization errors
    Exceptionerror.alertDialogError(e.toString());
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StudentViewModel(Supabase.instance.client),
        ),
        //ChangeNotifierProvider(
        // create: (_) => AdminViewModel(Supabase.instance.client),this model is not instantiated
        // ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Student Assistant',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 34, 241, 110),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        initialRoute: RouteManager.authGate,
        onGenerateRoute: RouteManager.generateRoute,
      ),
    );
  }
}
