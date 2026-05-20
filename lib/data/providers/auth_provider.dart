import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth/auth_service.dart';

/// Provider for managing authentication state across the app.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String? _error;
  User? _user;
  bool _isPremium = false;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
    _user = _authService.currentUser;
  }

  // ─── Getters ───────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isPremium => _isPremium;
  String get displayName => _user?.displayName ?? _user?.email ?? 'User';
  String? get email => _user?.email;
  String? get photoUrl => _user?.photoURL;

  // ─── Email/Password ────────────────────────────────────────────────────────

  /// Register with email and password.
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (result.isSuccess) {
      _user = result.user;
      _setLoading(false);
      return true;
    } else {
      _error = result.error;
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with email and password.
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      _user = result.user;
      _setLoading(false);
      return true;
    } else {
      _error = result.error;
      _setLoading(false);
      return false;
    }
  }

  // ─── Social Sign-In ────────────────────────────────────────────────────────

  /// Sign in with Google.
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithGoogle();

    if (result.isSuccess) {
      _user = result.user;
      _setLoading(false);
      return true;
    } else {
      _error = result.error;
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with Apple.
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithApple();

    if (result.isSuccess) {
      _user = result.user;
      _setLoading(false);
      return true;
    } else {
      _error = result.error;
      _setLoading(false);
      return false;
    }
  }

  // ─── Password Reset ────────────────────────────────────────────────────────

  /// Send password reset email.
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.sendPasswordReset(email);

    _setLoading(false);
    if (!result.isSuccess) {
      _error = result.error;
      return false;
    }
    return true;
  }

  // ─── Sign Out ──────────────────────────────────────────────────────────────

  /// Sign out.
  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _user = null;
    _isPremium = false;
    _setLoading(false);
  }

  // ─── Premium ───────────────────────────────────────────────────────────────

  /// Set premium status (called after purchase verification).
  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
