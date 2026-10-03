import 'dart:convert';

class AttendeeData {
  final String name;
  final String email;
  final String countryCode;
  final String phoneNumber;
  final String organization;
  final String passCode;
  final String status;
  final String eventTitle;
  final String eventLocation;
  final String registreeId;
  final String registrationId;

  const AttendeeData({
    required this.name,
    required this.email,
    required this.countryCode,
    required this.phoneNumber,
    required this.organization,
    required this.passCode,
    required this.status,
    required this.eventTitle,
    required this.eventLocation,
    required this.registreeId,
    required this.registrationId,
  });

  factory AttendeeData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> asMap(dynamic value) {
      if (value == null) return {};
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      if (value is String && value.isNotEmpty) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }
      return {};
    }

    final raw = json['data'];
    final data = asMap(raw);
    final event = asMap(data['eventId']);
    final location = asMap(event['location']);

    return AttendeeData(
      name: data['name']?.toString() ?? '—',
      email: data['email']?.toString() ?? '—',
      countryCode: data['countryCode']?.toString() ?? '',
      phoneNumber: data['phoneNumber']?.toString() ?? '—',
      organization: data['organization']?.toString() ?? '—',
      passCode: data['passCode']?.toString() ?? '—',
      status: data['status']?.toString() ?? '—',
      eventTitle: event['title']?.toString() ?? '—',
      eventLocation: location['address']?.toString() ?? '—',
      registreeId: data['registreeId']?.toString() ?? '',
      registrationId: data['id']?.toString() ?? '',
    );
  }

  bool get isAlreadyCheckedIn => status == 'CHECKED_IN';
}