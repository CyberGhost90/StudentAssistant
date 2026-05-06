import 'package:flutter/material.dart';
import 'package:student_assistant/models/exceptionError.dart';
import 'package:student_assistant/routes/routemanager.dart';
import 'package:student_assistant/viewmodels/student_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  try {
    // Initialize Supabase client
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: 'https://wjcpciamdrfxxnfbvbpg.supabase.co',
      anonKey: 'sb_publishable_iVYsr0v8swgI2HD0vER2JQ_QVkXeq5E',
    );

    runApp(const MainApp());
  } catch (e) {
    // Handle initialization errors if necessary
    Exceptionerror.AlertDialogError(e.toString() as BuildContext);
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

        initialRoute: RouteManager.splash,
        onGenerateRoute: RouteManager.GenerateRoute,
      ),
    );
  }
}
