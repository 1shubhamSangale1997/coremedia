import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:coremedia/services/attendance_api_service.dart';
import 'package:coremedia/screens/details_screen.dart';
import 'package:coremedia/screens/already_checked_in_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _cameraController;
  late AnimationController _lineController;
  late Animation<double> _lineAnim;

  bool _flashOn = false;
  bool _scanned = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _lineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned || _loading) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawValue = barcode.rawValue!.trim();
    setState(() {
      _scanned = true;
      _loading = true;
    });
    _cameraController.stop();

    String passCode = rawValue;
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is Map) {
        passCode = decoded['passCode']?.toString() ??
            decoded['passcode']?.toString() ??
            decoded['pass_code']?.toString() ??
            decoded['code']?.toString() ??
            rawValue;
      }
    } catch (_) {}

    final attendee =
        await AttendanceApiService.fetchAttendeeByPassCode(passCode);

    if (!mounted) return;
    setState(() => _loading = false);

    if (attendee != null) {
      if (attendee.isAlreadyCheckedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AlreadyCheckedInScreen(
              attendee: attendee,
              passCode: passCode,
              message: 'This attendee has already been checked in.',
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => DetailsScreen(attendee: attendee)),
        );
      }
    } else {
      _showScanError(
          'Attendee not found. Please check the QR code and try again.');
      setState(() => _scanned = false);
      _cameraController.start();
    }
  }

  void _showScanError(String message) {
    if (!mounted) return;
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

  void _toggleFlash() async {
    await _cameraController.toggleTorch();
    setState(() => _flashOn = !_flashOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Scan QR Code',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white),
            onPressed: _toggleFlash,
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const Spacer(),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 260,
                        height: 260,
                        child: MobileScanner(
                          controller: _cameraController,
                          onDetect: _onDetect,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white24, width: 1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    ..._buildCorners(260),
                    AnimatedBuilder(
                      animation: _lineAnim,
                      builder: (_, __) {
                        return Positioned(
                          top: 20 + (_lineAnim.value * 220),
                          child: Container(
                            width: 240,
                            height: 2.5,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF00E676),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Align the QR code within the\nframe to record attendance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.6),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withOpacity(0.6)),
                  ),
                  const SizedBox(width: 8),
                  Text('Scanning…',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: _toggleFlash,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 48),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          _flashOn
                              ? Icons.flash_on
                              : Icons.flashlight_on,
                          color: Colors.white,
                          size: 18),
                      const SizedBox(width: 8),
                      const Text('Flashlight',
                          style: TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_loading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Fetching attendee details…',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners(double size) {
    const len = 28.0;
    const thick = 3.5;
    const color = Color(0xFF00E676);

    Widget corner(bool top, bool left) {
      return Positioned(
        top: top ? 0 : null,
        bottom: top ? null : 0,
        left: left ? 0 : null,
        right: left ? null : 0,
        child: SizedBox(
          width: len,
          height: len,
          child: CustomPaint(
            painter: _CornerPainter(
                top: top, left: left, color: color, thickness: thick),
          ),
        ),
      );
    }

    return [
      corner(true, true),
      corner(true, false),
      corner(false, true),
      corner(false, false),
    ];
  }
}

class _CornerPainter extends CustomPainter {
  final bool top, left;
  final Color color;
  final double thickness;
  const _CornerPainter(
      {required this.top,
      required this.left,
      required this.color,
      required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final dx = left ? size.width : -size.width;
    final dy = top ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}