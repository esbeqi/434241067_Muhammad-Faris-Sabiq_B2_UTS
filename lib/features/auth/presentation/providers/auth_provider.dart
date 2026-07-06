import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  Map<String, dynamic>? _profile;
  bool _isLoading = false;

  User? get user => _user;
  String? get role => _profile?['role'];
  String? get fullName => _profile?['full_name'];
  bool get notificationEnabled => _profile?['notification_enabled'] ?? false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _user = _authService.currentSession?.user;
    if (_user != null) {
      loadProfile();
    }
  }

  Future<void> loadProfile() async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();
    
    _profile = await _authService.getUserProfile(_user!.id);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.login(email, password);
      _user = response.user;
      await loadProfile();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.register(email, password, fullName);
      return true;
    } catch (e) {
      debugPrint('Register error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNotification(bool enabled) async {
    if (_user == null) return;
    try {
      await _authService.updateNotification(_user!.id, enabled);
      _profile?['notification_enabled'] = enabled;
      notifyListeners();
    } catch (e) {
      debugPrint('Update notification error: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    await _authService.forgotPassword(email);
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _profile = null;
    notifyListeners();
  }

  bool get isAuthenticated => _user != null;
}
