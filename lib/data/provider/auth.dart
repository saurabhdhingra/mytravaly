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

  void _loadInitialToken() {
    _visitorToken = _authService.getVisitorToken();
    _isLoading = false;
    notifyListeners();
  }

  void setVisitorToken(String token) {
    _visitorToken = token;
    notifyListeners();
  }

  Future<void> signInAndRegister() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); 

    final token = await _authService.registerDevice();

    if (token != null) {
      setVisitorToken(token);
    }

    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    await _authService.clearVisitorToken();
    
    _visitorToken = null;
    
    _isLoading = false;
    notifyListeners();
  }
}