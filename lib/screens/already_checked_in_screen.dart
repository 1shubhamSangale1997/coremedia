import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coremedia/models/attendee_data.dart';
import 'package:coremedia/widgets/info_row.dart';

class AlreadyCheckedInScreen extends StatelessWidget {
  final AttendeeData? attendee;
  final String passCode;
  final String message;

  const AlreadyCheckedInScreen({
    super.key,
    required this.attendee,
    required this.passCode,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final a = attendee;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Attendance Status',
            style: TextStyle(
                color: Color(0xFF0D0D0D),
                fontWeight: FontWeight.w700,
                fontSize: 17)),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFF1FBF4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF2E9E5B), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                        color: Color(0xFF2E9E5B),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Already Checked In',
                            style: TextStyle(
                                color: Color(0xFF1B6B3A),
                                fontWeight: FontWeight.w800,
                                fontSize: 15)),
                        const SizedBox(height: 3),
                        Text(
                          'This attendee has already been\nmarked present for this event.',
                          style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (a != null) ...[
              const Text('Attendee',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9E9E9E),
                      letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(a.name,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB5173A),
                      height: 1.1)),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    InfoRow(icon: Icons.person_outline_rounded, label: 'Name', value: a.name),
                    const RowDivider(),
                    InfoRow(icon: Icons.phone_outlined, label: 'Mobile', value: '${a.countryCode} ${a.phoneNumber}'),
                    const RowDivider(),
                    InfoRow(icon: Icons.mail_outline_rounded, label: 'Email', value: a.email),
                    const RowDivider(),
                    InfoRow(icon: Icons.event_outlined, label: 'Event', value: a.eventTitle),
                    const RowDivider(),
                    InfoRow(icon: Icons.location_on_outlined, label: 'Venue', value: a.eventLocation),
                    const RowDivider(),
                    InfoRow(icon: Icons.business_outlined, label: 'Organization', value: a.organization),
                    const RowDivider(),
                    InfoRow(icon: Icons.confirmation_number_outlined, label: 'Pass Code', value: a.passCode),
                    const RowDivider(),
                    InfoRow(
                      icon: Icons.verified_outlined,
                      label: 'Status',
                      value: a.status.replaceAll('_', ' '),
                      valueColor: const Color(0xFF2E9E5B),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    InfoRow(icon: Icons.confirmation_number_outlined, label: 'Pass Code', value: passCode),
                    const RowDivider(),
                    const InfoRow(
                      icon: Icons.info_outline_rounded,
                      label: 'Status',
                      value: 'CHECKED IN',
                      valueColor: Color(0xFF2E9E5B),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5173A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Back to Home',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}