import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // GET CURRENT SESSION
  Session? get currentSession => _supabase.auth.currentSession;

  // GET USER PROFILE
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // UPDATE NOTIFICATION SETTING
  Future<void> updateNotification(String userId, bool enabled) async {
    await _supabase
        .from('profiles')
        .update({'notification_enabled': enabled})
        .eq('id', userId);
  }

  // LOGIN
  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // REGISTER
  Future<AuthResponse> register(String email, String password, String fullName) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user != null) {
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'full_name': fullName,
        'email': email,
        'role': 'user',
        'notification_enabled': true,
      });
    }
    return response;
  }

  // FORGOT PASSWORD
  Future<void> forgotPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // LOGOUT
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
