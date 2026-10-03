import 'package:flutter/material.dart';

class CoreLogo extends StatelessWidget {
  final double size;
  const CoreLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _LogoLetter(letter: 'C', size: size),
        _LogoTarget(size: size),
        _LogoLetter(letter: 'R', size: size),
        _LogoLetter(letter: 'E', size: size),
      ],
    );
  }
}

class _LogoLetter extends StatelessWidget {
  final String letter;
  final double size;
  const _LogoLetter({required this.letter, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      letter,
      style: TextStyle(
        fontSize: size * 0.55,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF0D0D0D),
        height: 1,
      ),
    );
  }
}

class _LogoTarget extends StatelessWidget {
  final double size;
  const _LogoTarget({required this.size});

  @override
  Widget build(BuildContext context) {
    final double d = size * 0.52;
    return SizedBox(
      width: d,
      height: d,
      child: CustomPaint(painter: _TargetPainter()),
    );
  }
}

class _TargetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final black = Paint()
      ..color = const Color(0xFF0D0D0D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.22;

    final red = Paint()
      ..color = const Color(0xFFCC0000)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), r * 0.85, black);
    canvas.drawCircle(Offset(cx, cy), r * 0.42, red);
  }

  @override
  bool shouldRepaint(_) => false;
}