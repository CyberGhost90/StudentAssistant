import 'package:flutter/material.dart';
import 'package:student_assistant/feature/auth/auth_service.dart';
import 'package:student_assistant/routes/routemanager.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //auth service
  final AuthService _authService = AuthService();
  //form key
  final _formKey = GlobalKey<FormState>();

  //text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //login function
  void login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      await _authService.signInWithEmailPassword(email, password);
      // Navigate to home screen on successful login
      if (email.contains('@stud.cut.ac.za')) {
        Navigator.pushAndRemoveUntil(
          context,
          RouteManager.studHome as Route<Object?>,
          (route) => false,
        );
      } else if (email.contains('@cut.ac.za')) {
        Navigator.pushAndRemoveUntil(
          context,
          RouteManager.adminHome as Route<Object?>,
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please use appropriate email to login.'),
          ),
        );
      }
    } catch (e) {
      // Show error message on login failure
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //INSERT LOGO AND INFOGRAPH HERE
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                icon: Icon(Icons.email),
                hintText: 'Enter your email',
              ),

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),

            SizedBox(height: 20),

            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                icon: Icon(Icons.lock),
                hintText: 'Enter your password',
              ),

              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  login();
                }
              },
              child: const Text('Login'),
            ),

            SizedBox(width: 8),

            Text("Don't have an account?"),
            TextButton(
              onPressed: () {
                // Navigate to the register page
                Navigator.pushAndRemoveUntil(
                  context,
                  RouteManager.register as MaterialPageRoute,
                  (route) => false,
                );
              },
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
