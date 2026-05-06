import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'views/application_form_screen.dart';
import 'view_models/student_view_model.dart';

Future<void> main() async {
  try {
    // Initialize Supabase client here if needed
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: 'https://wjcpciamdrfxxnfbvbpg.supabase.co',
      anonKey: 'sb_publishable_iVYsr0v8swgI2HD0vER2JQ_QVkXeq5E',
    );

    runApp(const MainApp());
  } catch (e) {
    // Handle initialization errors if necessary
    print('Error initializing Supabase: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => StudentViewModel(Supabase.instance.client),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Student Assistant',
        theme: ThemeData(primarySwatch: Colors.blue),

        // Define routes
        routes: {'/form': (context) => const ApplicationFormScreen()},

        // Decide which route loads first
        initialRoute: '/form',
      ),
    );
  }
}
