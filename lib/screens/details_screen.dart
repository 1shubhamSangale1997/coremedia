import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coremedia/models/attendee_data.dart';
import 'package:coremedia/models/api_result.dart';
import 'package:coremedia/services/attendance_api_service.dart';
import 'package:coremedia/widgets/info_row.dart';
import 'package:coremedia/widgets/thank_you_dialog.dart';
import 'package:coremedia/screens/already_checked_in_screen.dart';

class DetailsScreen extends StatefulWidget {
  final AttendeeData attendee;
  const DetailsScreen({super.key, required this.attendee});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _verified = false;
  bool _loading = false;

  Future<void> _markVerified() async {
    setState(() => _loading = true);
    final result =
        await AttendanceApiService.checkIn(widget.attendee.passCode);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      if (result.resultType == CheckInResultType.alreadyCheckedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AlreadyCheckedInScreen(
              attendee: result.attendee ?? widget.attendee,
              passCode: widget.attendee.passCode,
              message: result.message,
            ),
          ),
        );
      } else {
        setState(() => _verified = true);
        _showThankYouDialog();
      }
    } else {
      _showErrorSnackbar(result.message);
    }
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ThankYouDialog(
        name: widget.attendee.name,
        onDismiss: () {
          Navigator.of(context).pop();
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(message,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white))),
          ],
        ),
        backgroundColor: const Color(0xFFB5173A),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.attendee;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Event Details',
            style: TextStyle(
                color: Color(0xFF0D0D0D),
                fontWeight: FontWeight.w700,
                fontSize: 17)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF0D0D0D), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Welcome',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D0D0D),
                    height: 1.1)),
            Text(a.name,
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB5173A),
                    height: 1.1)),
            const SizedBox(height: 8),
            Text(
              'Access your event information and\nverify your attendance below.',
              style: TextStyle(
                  fontSize: 14, color: Colors.grey[500], height: 1.6),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(20),
              ),
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
                    icon: Icons.info_outline_rounded,
                    label: 'Status',
                    value: a.status.replaceAll('_', ' '),
                    valueColor: a.isAlreadyCheckedIn
                        ? const Color(0xFF2E9E5B)
                        : const Color(0xFF0D0D0D),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_verified || _loading) ? null : _markVerified,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E9E5B),
                  disabledBackgroundColor:
                      const Color(0xFF2E9E5B).withOpacity(0.5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_verified)
                            const Icon(Icons.check_circle, size: 18),
                          if (_verified) const SizedBox(width: 8),
                          Text(
                            _verified ? 'Presented ✓' : 'Tap to Present',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
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