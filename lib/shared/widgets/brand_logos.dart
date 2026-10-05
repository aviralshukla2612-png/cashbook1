import 'package:flutter/material.dart';

class InstagramRealLogo extends StatelessWidget {
  final double size;
  const InstagramRealLogo({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const RadialGradient(
          center: Alignment(-0.6, 1.1),
          radius: 1.4,
          colors: [
            Color(0xFFFCCC63), // Yellow
            Color(0xFFF56040), // Orange
            Color(0xFFDD2A7B), // Pink / Red
            Color(0xFF8134AF), // Purple
            Color(0xFF515BD4), // Royal Blue / Purple
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.65,
          height: size * 0.65,
          child: CustomPaint(
            painter: _InstagramPainter(),
          ),
        ),
      ),
    );
  }
}

class _InstagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.09;
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Outer camera frame (rounded square)
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(size.width * 0.26),
    );
    canvas.drawRRect(outerRect, strokePaint);

    // Center lens circle
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.24, strokePaint);

    // Top right flash dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.73, size.height * 0.27),
      size.width * 0.065,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LinkedInRealLogo extends StatelessWidget {
  final double size;
  const LinkedInRealLogo({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2), // LinkedIn Official Blue
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: _LinkedInPainter(),
        ),
      ),
    );
  }
}

class _LinkedInPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 'i' dot
    canvas.drawCircle(Offset(w * 0.16, h * 0.16), w * 0.12, fillPaint);

    // 'i' stem
    final iStem = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05, h * 0.38, w * 0.22, h * 0.62),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(iStem, fillPaint);

    // 'n' stem & arch
    final path = Path();

    // Left stem of 'n'
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.38, w * 0.22, h * 0.62),
        Radius.circular(w * 0.04),
      ),
    );

    // Curve arch & right stem of 'n'
    final arch = Path()
      ..moveTo(w * 0.58, h * 0.52)
      ..cubicTo(w * 0.58, h * 0.40, w * 0.68, h * 0.36, w * 0.80, h * 0.36)
      ..cubicTo(w * 0.94, h * 0.36, w * 0.98, h * 0.44, w * 0.98, h * 0.58)
      ..lineTo(w * 0.98, h * 1.0)
      ..lineTo(w * 0.77, h * 1.0)
      ..lineTo(w * 0.77, h * 0.60)
      ..cubicTo(w * 0.77, h * 0.52, w * 0.73, h * 0.49, w * 0.67, h * 0.49)
      ..cubicTo(w * 0.60, h * 0.49, w * 0.58, h * 0.54, w * 0.58, h * 0.62)
      ..lineTo(w * 0.58, h * 1.0)
      ..lineTo(w * 0.38, h * 1.0)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(arch, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
