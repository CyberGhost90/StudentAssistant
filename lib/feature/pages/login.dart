import 'package:flutter/material.dart';
import 'package:student_assistant/feature/auth/auth_service.dart';
import 'package:student_assistant/routes/routemanager.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //auth service and form key
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  //text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading=false;

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //login function
  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(()=>_isLoading=true);

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    try {
      await _authService.signInWithEmailPassword(email, password);

      if(!mounted) return;

      // Navigate to home screen on successful login
      if (email.contains('@stud.cut.ac.za')) {
        Navigator.pushReplacementNamed(context, RouteManager.studHome);
      } else if (email.contains('@cut.ac.za')) {
        Navigator.pushReplacementNamed(context, RouteManager.adminHome);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please use a valid CUT email address (@stud.cut.ac.za or @cut.ac.za).'),
          ),
        );
      }
    } catch (e) {
      if(!mounted) return;
      // Show error message on login failure
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }finally{
      if(mounted) setState(()=> _isLoading=false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40,),
                //Logo/header
                const Icon(Icons.school, size: 80, color: Colors.indigo),
                const SizedBox(height: 16),
                const Text('Student Assistant Portal',textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),),
                const SizedBox(height: 8),
                const Text('CUT - Department of IT',textAlign: TextAlign.center,style: TextStyle(color: Colors.grey),),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Enter your CUT email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                      }
                    if(!value.contains('@'))
                    {
                      return 'Please enter a valid email';
                      }
                      return null;
                      },
                 ),
                 const SizedBox(height: 20),
                 TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    hintText: 'Enter your password',
                  ),
                  obscureText: true,
                  validator: (value) {
                  if (value == null || value.isEmpty) 
                  {
                    return 'Please enter your password';
                  }
                  return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading?const SizedBox(height:20, width:20,child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,)): const Text('Login'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, RouteManager.register);
                      },
                      child: const Text('Sign Up', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                    )
                  ],
                )
          ],
        ),
          )
        )
      )
    );
  }
}
