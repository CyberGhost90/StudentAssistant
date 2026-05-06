import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  //sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      // Handle sign-in errors
      rethrow;
    }
  }

  //Register with email and password
  Future<AuthResponse> registerWithEmail(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      // Handle registration errors
      rethrow;
    }
  }

  //Sign out
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      // Handle sign-out errors
      rethrow;
    }
  }

  //get user email
  String? getUserEmail() {
    final user = _supabaseClient.auth.currentUser;
    return user?.email;
  }
}
