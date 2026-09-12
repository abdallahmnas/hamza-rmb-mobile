import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../storage/local_storage.dart';

// ── Auth State ─────────────────────────────────────────────────────────────
class AuthState {
  final bool isLoggedIn;
  final String? email;
  final String? displayName;

  const AuthState({this.isLoggedIn = false, this.email, this.displayName});

  AuthState copyWith({bool? isLoggedIn, String? email, String? displayName}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }

  Map<String, dynamic> toJson() => {
    'isLoggedIn': isLoggedIn,
    'email': email,
    'displayName': displayName,
  };

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
    );
  }
}

// ── Auth Service ───────────────────────────────────────────────────────────
class AuthService extends Notifier<AuthState> {
  static const String _storageKey = 'auth_user';

  @override
  AuthState build() {
    final storage = ref.watch(localStorageProvider);
    final json = storage.getString(_storageKey);
    if (json != null) {
      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        return AuthState.fromJson(data);
      } catch (_) {
        return const AuthState();
      }
    }
    return const AuthState();
  }

  /// Check if user is currently authenticated.
  bool get isAuthenticated => state.isLoggedIn;

  /// Get the current user info (returns null values if not logged in).
  AuthState get currentUser => state;

  /// Log in with any non-empty credentials (test mode).
  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    // Extract a display name from the email
    final displayName = email.split('@').first;

    final newState = AuthState(
      isLoggedIn: true,
      email: email.trim(),
      displayName: displayName,
    );

    // Persist to SharedPreferences
    final storage = ref.read(localStorageProvider);
    await storage.setString(_storageKey, jsonEncode(newState.toJson()));
    state = newState;
    return true;
  }

  /// Log out — clear persisted state and reset.
  Future<void> logout() async {
    final storage = ref.read(localStorageProvider);
    await storage.remove(_storageKey);
    state = const AuthState();
  }
}

// ── Riverpod Provider ──────────────────────────────────────────────────────
final authServiceProvider = NotifierProvider<AuthService, AuthState>(() {
  return AuthService();
});
