import 'package:coremedia/models/attendee_data.dart';

enum CheckInResultType { freshCheckIn, alreadyCheckedIn }

class ApiResult {
  final bool success;
  final String message;
  final AttendeeData? attendee;
  final CheckInResultType resultType;

  const ApiResult._({
    required this.success,
    required this.message,
    this.attendee,
    this.resultType = CheckInResultType.freshCheckIn,
  });

  factory ApiResult.success({
    required String message,
    AttendeeData? attendee,
    CheckInResultType resultType = CheckInResultType.freshCheckIn,
  }) =>
      ApiResult._(
        success: true,
        message: message,
        attendee: attendee,
        resultType: resultType,
      );

  factory ApiResult.failure({required String message}) =>
      ApiResult._(success: false, message: message);
}