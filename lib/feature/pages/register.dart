import 'package:flutter/material.dart';
import 'package:student_assistant/feature/auth/auth_service.dart';
import 'package:student_assistant/models/admin_model.dart';
import 'package:student_assistant/models/student_model.dart';
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
  Admin admin = Admin(FirstName: '', Surname: '', email: '', password: '');
  Student student = Student(
    studentEmail: '',
    firstName: '',
    Surname: '',
    password: '',
  );

  //text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  //login function
  void register() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String firstName = _firstNameController.text;
    final String surname = _surnameController.text;

    try {
      await _authService.registerWithEmail(email, password);
      // Navigate to home screen on successful register
      if (email.contains('@stud.cut.ac.za')) {
        student = Student(
          studentEmail: email,
          firstName: firstName,
          Surname: surname,
          password: password,
        );

        Navigator.pushAndRemoveUntil(
          context,
          RouteManager.studHome as Route<Object?>,
          (route) => false,
        );
      } else if (email.contains('@cut.ac.za')) {
        admin = Admin(
          email: email,
          FirstName: firstName,
          Surname: surname,
          password: password,
        );

        Navigator.pushAndRemoveUntil(
          context,
          RouteManager.adminHome as Route<Object?>,
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please use appropriate email to register.'),
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
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                icon: Icon(Icons.person),
                hintText: 'Enter your first name',
              ),

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),

            SizedBox(height: 20),

            TextFormField(
              controller: _surnameController,
              decoration: const InputDecoration(
                labelText: 'Surname',
                icon: Icon(Icons.person),
                hintText: 'Enter your surname',
              ),

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your surname';
                }
                return null;
              },
            ),

            SizedBox(height: 20),

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
                if (value == null || value.isEmpty || value.length < 8) {
                  return 'Please enter your password (at least 8 characters)';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                icon: Icon(Icons.lock),
                hintText: 'Enter your password again',
              ),

              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  register();
                }
              },
              child: const Text('Register'),
            ),

            SizedBox(width: 8),

            Text("Already have an account?"),
            TextButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.pushAndRemoveUntil(
                  context,
                  RouteManager.login as MaterialPageRoute,
                  (route) => false,
                );
              },
              child: Text(
                'Sign In',
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
