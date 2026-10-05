import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:coremedia/models/attendee_data.dart';
import 'package:coremedia/models/api_result.dart';
import 'package:coremedia/services/token_manager.dart';

class AttendanceApiService {
  // static const String _baseUrl = 'https://backend.uatcoremedia.vebsigns.com';
  static const String _baseUrl = 'https://api.core-mediagroup.com';

  static Future<Map<String, String>> _headers() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<AttendeeData?> fetchAttendeeByPassCode(String passCode) async {
    try {
      final headers = await _headers();
      final uri = Uri.parse(
        '$_baseUrl/api/v1/admin/attendees?page=1&limit=10&search=$passCode',
      );
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = _tryDecode(response.body);
        final outerData = body?['data'];
        if (outerData is Map) {
          final list = outerData['data'];
          if (list is List && list.isNotEmpty) {
            return AttendeeData.fromJson({
              'data': list[0] as Map<String, dynamic>,
            });
          }
        }
      }
    } catch (e) {
      debugPrint('[API] fetchAttendeeByPassCode error: $e');
    }
    return null;
  }

  static Future<ApiResult> checkIn(String passCode) async {
    try {
      final headers = await _headers();
      final uri = Uri.parse(
        '$_baseUrl/api/v1/admin/attendees/$passCode/check-in',
      );
      final response = await http
          .patch(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final body = _tryDecode(response.body);
        if (body != null && body['success'] == true && body['data'] != null) {
          return ApiResult.success(
            message: body['message'] ?? 'Attendance marked successfully.',
            attendee: AttendeeData.fromJson({'data': body['data']}),
            resultType: CheckInResultType.freshCheckIn,
          );
        }
        return ApiResult.success(
          message: 'Attendance marked successfully.',
          resultType: CheckInResultType.freshCheckIn,
        );
      }

      if (response.statusCode == 401) {
        TokenManager.invalidate();
        return ApiResult.failure(
          message: 'Session expired. Please scan again.',
        );
      }

      if (response.statusCode == 400) {
        final body = _tryDecode(response.body);
        if (body != null && body['data'] != null) {
          return ApiResult.success(
            message: body['message'] ?? 'Already checked in.',
            attendee: AttendeeData.fromJson({'data': body['data']}),
            resultType: CheckInResultType.alreadyCheckedIn,
          );
        }
        final attendee = await fetchAttendeeByPassCode(passCode);
        return ApiResult.success(
          message: 'Attendee is already checked in.',
          attendee: attendee,
          resultType: CheckInResultType.alreadyCheckedIn,
        );
      }

      final body = _tryDecode(response.body);
      return ApiResult.failure(
        message: body?['message'] ?? 'Server error (${response.statusCode}).',
      );
    } on http.ClientException catch (e) {
      return ApiResult.failure(message: 'Network error: ${e.message}');
    } catch (e) {
      return ApiResult.failure(message: 'Unexpected error: $e');
    }
  }

  static Map<String, dynamic>? _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }
}
