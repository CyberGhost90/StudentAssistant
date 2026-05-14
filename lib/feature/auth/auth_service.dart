import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  //sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(String email, String password,) async 
  {
    return await _supabaseClient.auth.signInWithPassword(email: email,password: password);
  }

  //Register with email and password
  Future<AuthResponse> registerWithEmail(String email, String password) async {
   return await _supabaseClient.auth.signUp(email: email, password: password);
  }

  //Sign out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  //get current user email
  String? getUserEmail() {
    return _supabaseClient.auth.currentUser?.id;
  }
}
