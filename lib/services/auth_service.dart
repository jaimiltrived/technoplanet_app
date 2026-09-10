// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'api_config.dart';
import 'api_service.dart';

/// Handles authentication against the live backend.
///
/// Token lifecycle:
///   login() → token received → ApiService.setToken() (in-memory)
///   logout() → POST /api/auth/logout → token cleared
class AuthService {
  static UserModel? _currentUser;
  static UserModel? get currentUser => _currentUser;

  // ── Login ─────────────────────────────────────────────────────────────────

  static Future<UserModel?> login(String email, String password) async {
    final trimmedEmail = email.trim().toLowerCase();

    try {
      final res = await ApiService.post(ApiConfig.login, {
        'email': trimmedEmail,
        'password': password,
      });

      // The live API wraps the payload in res['data'].
      // Extract token from wherever it lives in the response.
      final data = res['data'] as Map<String, dynamic>? ?? res;

      final accessToken = _extractToken(data);
      if (accessToken != null && accessToken.isNotEmpty) {
        ApiService.setToken(accessToken);
      }

      // Role string lives at top-level or inside data.
      final roleStr =
          (res['role'] ?? data['role'])?.toString();

      // User object may be nested under 'user', 'profile', or be flat.
      Map<String, dynamic> userJson;
      if (data['user'] is Map<String, dynamic>) {
        userJson = data['user'] as Map<String, dynamic>;
      } else if (data['profile'] is Map<String, dynamic>) {
        userJson = data['profile'] as Map<String, dynamic>;
      } else {
        userJson = data;
      }

      _currentUser = UserModel.fromJson(userJson, roleStr: roleStr);
      return _currentUser;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[AuthService] login error: $err');
      }
      rethrow;
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  static Future<UserModel?> fetchProfile() async {
    try {
      final res = await ApiService.get(ApiConfig.profile);
      // Handle: { success, data: { ...user fields } } or flat { ...user }
      final data = res['data'] as Map<String, dynamic>? ?? res;

      Map<String, dynamic> userJson;
      if (data['user'] is Map<String, dynamic>) {
        userJson = data['user'] as Map<String, dynamic>;
      } else if (data['profile'] is Map<String, dynamic>) {
        userJson = data['profile'] as Map<String, dynamic>;
      } else {
        userJson = data;
      }

      _currentUser = UserModel.fromJson(
        userJson,
        roleStr: _currentUser?.role.name.toUpperCase(),
      );
      return _currentUser;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[AuthService] fetchProfile error: $err');
      }
      // Return cached user on transient error so the UI isn't broken.
      return _currentUser;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  /// Calls `POST /api/auth/logout` to invalidate the server-side token,
  /// then clears the local state regardless of the server response.
  static Future<void> logout() async {
    try {
      await ApiService.post(ApiConfig.logout, {});
    } catch (err) {
      // Even if the server call fails, always clear local auth state.
      if (kDebugMode) {
        debugPrint('[AuthService] logout server call error (ignored): $err');
      }
    } finally {
      _currentUser = null;
      ApiService.setToken(null);
    }
  }

  // ── Change password ───────────────────────────────────────────────────────

  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final res = await ApiService.post(ApiConfig.changePassword, {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      return res['success'] == true ||
          (res['message'] as String?)?.toLowerCase().contains('success') ==
              true;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[AuthService] changePassword error: $err');
      }
      rethrow;
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  // ── Registration ──────────────────────────────────────────────────────────

  /// Registers a new student account.
  /// Returns the server message on success; throws [ApiException] on failure.
  static Future<String> register({
    required String name,
    required String email,
    required String password,
    required String rollNo,
    required String department,
    required int semester,
    required String phone,
  }) async {
    try {
      final res = await ApiService.postPublic(ApiConfig.register, {
        'name': name,
        'email': email,
        'password': password,
        'rollNo': rollNo,
        'department': department,
        'semester': semester,
        'phone': phone,
      });

      return (res['message'] as String?) ?? 'Registration successful!';
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[AuthService] register error: $err');
      }
      rethrow;
    }
  }

  // ── Internal helpers (private) ─────────────────────────────────────────────

  /// Searches common token field names in [data].
  static String? _extractToken(Map<String, dynamic> data) {
    return (data['accessToken'] ??
            data['token'] ??
            data['access_token'] ??
            data['jwt'])
        ?.toString();
  }
}
