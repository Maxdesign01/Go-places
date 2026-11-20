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
          icon: _buildGoogleLogo(),
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

  static Widget _buildGoogleLogo() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'G',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
