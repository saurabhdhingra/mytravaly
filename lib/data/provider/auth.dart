import 'package:flutter/material.dart';
import 'package:mytravaly/data/service/authentication.dart';

class AuthNotifier extends ChangeNotifier {
  String? _visitorToken;
  bool _isLoading = true;

  String? get visitorToken => _visitorToken;
  bool get isAuthenticated => _visitorToken != null;
  bool get isLoading => _isLoading;

  final AuthService _authService;

  AuthNotifier(this._authService) {
    _loadInitialToken();
  }

  /// Loads the token from persistent storage when the app starts.
  void _loadInitialToken() {
    _visitorToken = _authService.getVisitorToken();
    _isLoading = false;
    notifyListeners();
  }

  /// Updates the token after a successful registration.
  void setVisitorToken(String token) {
    _visitorToken = token;
    notifyListeners();
  }

  /// Simulates a Google Sign-In and performs device registration.
  Future<void> signInAndRegister() async {
    _isLoading = true;
    notifyListeners();

    // 1. Simulate Google Sign-In (Frontend-Only as requested)
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay

    // 2. Perform Device Registration
    final token = await _authService.registerDevice();

    if (token != null) {
      setVisitorToken(token);
    }

    _isLoading = false;
    notifyListeners();
  }
  
  /// Logs the user out by clearing the token and resetting state.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    // Clear the token from SharedPreferences
    await _authService.clearVisitorToken();
    
    // Clear the in-memory token
    _visitorToken = null;
    
    _isLoading = false;
    notifyListeners();
  }
}