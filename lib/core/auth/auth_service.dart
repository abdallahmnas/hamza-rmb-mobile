import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_remote_data_source.dart';
import '../../features/auth/models/user_model.dart';
import '../storage/local_storage.dart';

// ── Auth State ─────────────────────────────────────────────────────────────
class AuthState {
  final bool isLoggedIn;
  final String? token;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isLoggedIn = false,
    this.token,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  String? get email => user?.email;
  String? get displayName => user?.fullName;

  AuthState copyWith({
    bool? isLoggedIn,
    String? token,
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  Map<String, dynamic> toJson() => {
        'isLoggedIn': isLoggedIn,
        'token': token,
        'user': user?.toJson(),
      };

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      token: json['token'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ── Auth Service ───────────────────────────────────────────────────────────
class AuthService extends Notifier<AuthState> {
  static const String _userStorageKey = 'auth_user';
  static const String _tokenStorageKey = 'auth_token';

  @override
  AuthState build() {
    final storage = ref.watch(localStorageProvider);
    final token = storage.getString(_tokenStorageKey);
    final userJson = storage.getString(_userStorageKey);

    if (token != null && token.isNotEmpty) {
      UserModel? user;
      if (userJson != null) {
        try {
          user = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        } catch (_) {}
      }
      return AuthState(
        isLoggedIn: true,
        token: token,
        user: user,
      );
    }
    return const AuthState();
  }

  bool get isAuthenticated => state.isLoggedIn;
  UserModel? get currentUser => state.user;

  /// Register a new account
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final remoteSource = ref.read(authRemoteDataSourceProvider);
      final response = await remoteSource.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
      );

      final storage = ref.read(localStorageProvider);
      if (response.token != null) {
        await storage.setString(_tokenStorageKey, response.token!);
      }
      if (response.user != null) {
        await storage.setString(_userStorageKey, jsonEncode(response.user!.toJson()));
      }

      state = AuthState(
        isLoggedIn: response.token != null,
        token: response.token,
        user: response.user ??
            UserModel(
              id: 'temp',
              firstName: firstName,
              lastName: lastName,
              email: email,
              phone: phone,
            ),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Log in with email & password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final remoteSource = ref.read(authRemoteDataSourceProvider);
      final response = await remoteSource.login(
        email: email.trim(),
        password: password,
      );

      final token = response.token ?? 'session_${DateTime.now().millisecondsSinceEpoch}';
      final user = response.user ??
          UserModel(
            id: 'usr-current',
            firstName: email.split('@').first,
            lastName: '',
            email: email.trim(),
            phone: '',
            isVerified: true,
          );

      final storage = ref.read(localStorageProvider);
      await storage.setString(_tokenStorageKey, token);
      await storage.setString(_userStorageKey, jsonEncode(user.toJson()));

      state = AuthState(
        isLoggedIn: true,
        token: token,
        user: user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Verify 6-digit email OTP
  Future<bool> verifyOtp({required String email, required String otp}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final remoteSource = ref.read(authRemoteDataSourceProvider);
      final response = await remoteSource.verifyOtp(email: email, otp: otp);

      final storage = ref.read(localStorageProvider);
      if (response.token != null) {
        await storage.setString(_tokenStorageKey, response.token!);
      }

      final updatedUser = (response.user ?? state.user)?.copyWith(isVerified: true);
      if (updatedUser != null) {
        await storage.setString(_userStorageKey, jsonEncode(updatedUser.toJson()));
      }

      state = state.copyWith(
        isLoggedIn: true,
        token: response.token ?? state.token,
        user: updatedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp({required String email}) async {
    try {
      final remoteSource = ref.read(authRemoteDataSourceProvider);
      await remoteSource.resendOtp(email: email);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Refresh current user profile in background
  Future<void> refreshProfile() async {
    if (!state.isLoggedIn) return;
    try {
      final remoteSource = ref.read(authRemoteDataSourceProvider);
      final user = await remoteSource.getMe();
      final storage = ref.read(localStorageProvider);
      await storage.setString(_userStorageKey, jsonEncode(user.toJson()));
      state = state.copyWith(user: user);
    } catch (_) {
      // Retain cached user data silently on network failure
    }
  }

  /// Clear login session and cached data, resetting auth state to unauthenticated.
  Future<void> clearSessionAndCache() async {
    final storage = ref.read(localStorageProvider);
    await storage.clearSessionAndCache();
    state = const AuthState();
  }

  /// Log out — clear persisted auth data and reset state.
  Future<void> logout({bool clearAllCache = true}) async {
    final storage = ref.read(localStorageProvider);
    if (clearAllCache) {
      await storage.clearSessionAndCache();
    } else {
      await storage.remove(_tokenStorageKey);
      await storage.remove(_userStorageKey);
    }
    state = const AuthState();
  }
}

// ── Riverpod Provider ──────────────────────────────────────────────────────
final authServiceProvider = NotifierProvider<AuthService, AuthState>(() {
  return AuthService();
});

