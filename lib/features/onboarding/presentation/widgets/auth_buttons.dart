import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class AuthButtons extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  const AuthButtons({
    super.key,
    required this.onGooglePressed,
    required this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Continue with Google Button
        _buildPillButton(
          onTap: onGooglePressed,
          backgroundColor: isDark ? Colors.white : const Color(0xFF121212),
          textColor: isDark ? const Color(0xFF121212) : Colors.white,
          border: isDark ? Border.all(color: Colors.white) : null,
          icon: _buildGoogleLogo(isDark: isDark),
          label: 'Continue with Google',
        ),

        const SizedBox(height: 10),

        // Continue with Apple Button
        _buildPillButton(
          onTap: onApplePressed,
          backgroundColor: AppColors.surfaceSubtle,
          textColor: AppColors.textPrimary,
          border: Border.all(color: AppColors.borderHairline),
          icon: Icon(Icons.apple, color: AppColors.textPrimary, size: 22),
          label: 'Continue with Apple',
        ),
      ],
    );
  }

  static Widget _buildPillButton({
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color textColor,
    required Widget icon,
    required String label,
    Border? border,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: border,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildGoogleLogo({required bool isDark}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.white,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(2.5),
      child: const CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

/// Precise vector painter for the official 4-color Google "G" logo
class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;

    // Blue (#4285F4)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final bluePath = Path()
      ..moveTo(23.7450 * s, 12.2700 * s)
      ..cubicTo(23.7450 * s, 11.5700 * s, 23.6850 * s, 10.8700 * s, 23.5550 * s, 10.2000 * s)
      ..lineTo(12.0000 * s, 10.2000 * s)
      ..lineTo(12.0000 * s, 14.7100 * s)
      ..lineTo(18.6000 * s, 14.7100 * s)
      ..cubicTo(18.3100 * s, 16.2300 * s, 17.4600 * s, 17.5300 * s, 16.2000 * s, 18.3900 * s)
      ..lineTo(16.2000 * s, 21.4400 * s)
      ..lineTo(20.0800 * s, 21.4400 * s)
      ..cubicTo(22.3500 * s, 19.3500 * s, 23.7400 * s, 16.2700 * s, 23.7400 * s, 12.2700 * s)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Green (#34A853)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final greenPath = Path()
      ..moveTo(12.0000 * s, 24.0000 * s)
      ..cubicTo(15.2400 * s, 24.0000 * s, 17.9500 * s, 22.9200 * s, 19.9300 * s, 21.0900 * s)
      ..lineTo(16.0500 * s, 18.0400 * s)
      ..cubicTo(14.9700 * s, 18.7600 * s, 13.6000 * s, 19.2000 * s, 12.0000 * s, 19.2000 * s)
      ..cubicTo(8.8800 * s, 19.2000 * s, 6.2300 * s, 17.1000 * s, 5.2800 * s, 14.2700 * s)
      ..lineTo(1.2500 * s, 14.2700 * s)
      ..lineTo(1.2500 * s, 17.4200 * s)
      ..cubicTo(3.2600 * s, 21.4000 * s, 7.3400 * s, 24.0000 * s, 12.0000 * s, 24.0000 * s)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Yellow (#FBBC05)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final yellowPath = Path()
      ..moveTo(5.2800 * s, 14.2700 * s)
      ..cubicTo(5.0300 * s, 13.5500 * s, 4.9000 * s, 12.7800 * s, 4.9000 * s, 12.0000 * s)
      ..cubicTo(4.9000 * s, 12.0000 * s, 5.0300 * s, 10.4500 * s, 5.2800 * s, 9.7300 * s)
      ..lineTo(5.2800 * s, 6.5800 * s)
      ..lineTo(1.2500 * s, 6.5800 * s)
      ..cubicTo(0.4500 * s, 8.1800 * s, 0.0000 * s, 9.9900 * s, 0.0000 * s, 12.0000 * s)
      ..cubicTo(0.0000 * s, 12.0000 * s, 0.4500 * s, 15.8200 * s, 1.2500 * s, 17.4200 * s)
      ..lineTo(5.2800 * s, 14.2700 * s)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Red (#EA4335)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final redPath = Path()
      ..moveTo(12.0000 * s, 4.7500 * s)
      ..cubicTo(13.7700 * s, 4.7500 * s, 15.3500 * s, 5.3600 * s, 16.6000 * s, 6.5500 * s)
      ..lineTo(20.0200 * s, 3.1300 * s)
      ..cubicTo(17.9500 * s, 1.1900 * s, 15.2400 * s, 0.0000 * s, 12.0000 * s, 0.0000 * s)
      ..cubicTo(7.3400 * s, 0.0000 * s, 3.2600 * s, 2.6000 * s, 1.2500 * s, 6.5800 * s)
      ..lineTo(5.2800 * s, 9.7300 * s)
      ..cubicTo(6.2300 * s, 6.9000 * s, 8.8800 * s, 4.7500 * s, 12.0000 * s, 4.7500 * s)
      ..close();
    canvas.drawPath(redPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
