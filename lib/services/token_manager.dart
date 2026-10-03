import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TokenManager {
  static const String _baseUrl = 'https://backend.uatcoremedia.vebsigns.com';
  static const String _loginPath = '/api/v1/admin/auth/login';

  static String? _cachedToken;
  static DateTime? _expiresAt;

  // ── Called by LoginScreen with user-entered credentials ──────────────
  static Future<void> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl$_loginPath');
    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Login failed (${response.statusCode})');
    }

    final json = jsonDecode(response.body);
    final token =
        (json['data'] is Map ? json['data']['access_token']?.toString() : null) ??
            json['token']?.toString() ??
            json['accessToken']?.toString();

    if (token == null) throw Exception('No token in response');

    _cachedToken = token;
    _expiresAt =
        _jwtExpiry(token) ?? DateTime.now().add(const Duration(hours: 1));
    debugPrint('[Token] Login successful. Expires at $_expiresAt');
  }

  // ── Called internally by AttendanceApiService ────────────────────────
  static Future<String> getToken() async {
    if (_cachedToken != null &&
        _expiresAt != null &&
        DateTime.now().isBefore(
            _expiresAt!.subtract(const Duration(seconds: 60)))) {
      return _cachedToken!;
    }
    throw Exception('No active session. Please log in again.');
  }

  static void invalidate() {
    _cachedToken = null;
    _expiresAt = null;
  }

  static DateTime? _jwtExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      String payload = parts[1];
      payload += '=' * ((4 - payload.length % 4) % 4);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = map['exp'];
      if (exp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    } catch (_) {
      return null;
    }
  }
}