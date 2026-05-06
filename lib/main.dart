import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
