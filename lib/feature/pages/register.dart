import 'package:flutter/material.dart';
import 'package:student_assistant/feature/auth/auth_service.dart';
import 'package:student_assistant/routes/route_manager.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterLoginState();
}

class _RegisterLoginState extends State<Register> {
  //auth service and form key
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  //text controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading=false;

  @override
  void dispose(){
    _firstNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //login function
  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(()=>_isLoading=true);

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    try {
      await _authService.registerWithEmail(email, password);

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24,),
                //Logo/header
                const Icon(Icons.person_add, size: 64, color: Colors.indigo),
                const SizedBox(height: 12),
                const Text('Create Account',textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Enter your first name',
                  ),
                  validator: (value) {
                  if (value == null || value.isEmpty) 
                  {
                    return 'Please enter your first name';
                  }
                  return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(
                    labelText: 'Surname',
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'Enter your surname',
                  ),
<<<<<<< HEAD
=======
                  obscureText: false,
>>>>>>> 787090bc7979e4900506738266bd69723397e05d
                  validator: (value) {
                  if (value == null || value.isEmpty) 
                  {
                    return 'Please enter your surname';
                  }
                  return null;
                  },
                ),
                const SizedBox(height: 16),
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
                    if(!value.contains('@stud.cut.ac.za') && !value.contains('@cut.ac.za'))
                    {
                      return 'Please enter a valid CUT email address';
                      }
                      return null;
                      },
                 ),
                 const SizedBox(height: 16),
                 TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    hintText: 'At least 8 characters',
                  ),
                  obscureText: true,
                  validator: (value) {
                  if (value == null || value.length <8) 
                  {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: 'Re-enter your password',
                  ),
                  obscureText: true,
                  validator: (value) {
                  if (value == null || value.isEmpty) 
                  {
                    return 'Please confirm your password';
                  }
                  if(value != _passwordController.text)
                  {
                    return 'Passwords do not match';
                  }
                  return null;
                  },
                ),
                const SizedBox(height: 24,),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading?const SizedBox(height:20, width:20,child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,)): const Text('Register'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, RouteManager.login);
                      },
                      child: const Text('Sign In', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
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
