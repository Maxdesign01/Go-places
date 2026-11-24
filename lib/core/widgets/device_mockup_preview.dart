import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Interactive Device Mockup Shell for Antigravity & Web Previews.
/// Wraps the mobile app in an ultra-realistic smartphone frame when previewed
/// on desktop/wide screens, while automatically displaying full-screen on mobile.
class DeviceMockupPreview extends StatefulWidget {
  final Widget child;

  const DeviceMockupPreview({
    super.key,
    required this.child,
  });

  @override
  State<DeviceMockupPreview> createState() => _DeviceMockupPreviewState();
}

class _DeviceMockupPreviewState extends State<DeviceMockupPreview> {
  bool _isMockupActive = true;
  bool _isLandscape = false;
  String _selectedDevice = 'iPhone 16 Pro';

  // Device specs (Logical resolution and safe area insets)
  static const Map<String, Map<String, dynamic>> _devices = {
    'iPhone 16 Pro': {
      'size': Size(393, 852),
      'safeArea': EdgeInsets.only(top: 54, bottom: 34),
      'radius': 52.0,
      'hasDynamicIsland': true,
    },
    'Pixel 9': {
      'size': Size(412, 915),
      'safeArea': EdgeInsets.only(top: 48, bottom: 28),
      'radius': 44.0,
      'hasDynamicIsland': false,
    },
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Automatically bypass mockup if screen is already a physical mobile device width
        final isSmallScreen = constraints.maxWidth < 600;

        if (isSmallScreen || !_isMockupActive) {
          return Stack(
            children: [
              widget.child,
              // If on desktop and user switched to Web view, keep a small floating toggle to return to Mockup
              if (!isSmallScreen)
                Positioned(
                  top: 16,
                  right: 16,
                  child: SafeArea(
                    child: _buildFloatingDockButton(
                      icon: Icons.phone_iphone_rounded,
                      label: 'Switch to Mobile Mockup',
                      onTap: () => setState(() => _isMockupActive = true),
                    ),
                  ),
                ),
            ],
          );
        }

        final device = _devices[_selectedDevice] ?? _devices['iPhone 16 Pro']!;
        final rawSize = device['size'] as Size;
        final rawSafeArea = device['safeArea'] as EdgeInsets;
        final cornerRadius = device['radius'] as double;
        final hasDynamicIsland = device['hasDynamicIsland'] as bool;

        final deviceSize = _isLandscape
            ? Size(rawSize.height, rawSize.width)
            : rawSize;

        final safeArea = _isLandscape
            ? EdgeInsets.only(
                left: rawSafeArea.top,
                right: rawSafeArea.top,
                bottom: rawSafeArea.bottom,
              )
            : rawSafeArea;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0C13),
          body: Stack(
            children: [
              // Subtle ambient background gradient & dot grid
              Positioned.fill(
                child: CustomPaint(
                  painter: _StudioBackgroundPainter(
                    isDark: AppColors.isDark,
                  ),
                ),
              ),

              // Main Phone Canvas area
              Positioned.fill(
                child: Column(
                  children: [
                    // Top Floating Control Bar
                    const SizedBox(height: 16),
                    _buildTopToolbar(),

                    // Phone Mockup Area (Scales smoothly to fit available height)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: _buildRealisticPhone(
                              deviceSize: deviceSize,
                              safeArea: safeArea,
                              cornerRadius: cornerRadius,
                              hasDynamicIsland: hasDynamicIsland,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Floating Toolbar to toggle views and devices
  Widget _buildTopToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161822).withOpacity(0.92),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mobile Mockup Segment
          _buildSegmentButton(
            icon: Icons.phone_iphone_rounded,
            label: 'Mobile',
            isActive: _isMockupActive,
            onTap: () {
              if (!_isMockupActive) setState(() => _isMockupActive = true);
            },
          ),
          const SizedBox(width: 4),

          // Full Web Segment
          _buildSegmentButton(
            icon: Icons.laptop_rounded,
            label: 'Web',
            isActive: !_isMockupActive,
            onTap: () {
              if (_isMockupActive) setState(() => _isMockupActive = false);
            },
          ),
          const SizedBox(width: 12),

          // Divider
          Container(
            height: 20,
            width: 1,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(width: 12),

          // Device Selector
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDevice,
              dropdownColor: const Color(0xFF1C1E2A),
              borderRadius: BorderRadius.circular(16),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.white.withOpacity(0.8),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              items: _devices.keys.map((String deviceName) {
                return DropdownMenuItem<String>(
                  value: deviceName,
                  child: Text(deviceName),
                );
              }).toList(),
              onChanged: (newDevice) {
                if (newDevice != null) {
                  setState(() => _selectedDevice = newDevice);
                }
              },
            ),
          ),
          const SizedBox(width: 8),

          // Rotate Button
          IconButton(
            tooltip: 'Rotate Orientation',
            icon: Icon(
              Icons.screen_rotation_rounded,
              size: 18,
              color: _isLandscape
                  ? AppColors.accentCoral
                  : Colors.white.withOpacity(0.7),
            ),
            onPressed: () => setState(() => _isLandscape = !_isLandscape),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.black : Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white.withOpacity(0.7),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingDockButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF161822).withOpacity(0.92),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the realistic phone mockup with hardware bezels, buttons, shadow, and screen
  Widget _buildRealisticPhone({
    required Size deviceSize,
    required EdgeInsets safeArea,
    required double cornerRadius,
    required bool hasDynamicIsland,
  }) {
    const bezelWidth = 12.0;
    const buttonThickness = 3.5;

    final phoneOuterWidth = deviceSize.width + (bezelWidth * 2);
    final phoneOuterHeight = deviceSize.height + (bezelWidth * 2);

    return SizedBox(
      width: phoneOuterWidth + (buttonThickness * 2) + 20,
      height: phoneOuterHeight + 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Realistic Multi-stage 3D Drop Shadow
          Container(
            width: phoneOuterWidth,
            height: phoneOuterHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius + bezelWidth),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.65),
                  blurRadius: 55,
                  spreadRadius: 8,
                  offset: const Offset(0, 24),
                ),
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.35),
                  blurRadius: 80,
                  spreadRadius: 18,
                  offset: const Offset(0, 36),
                ),
              ],
            ),
          ),

          // Hardware Buttons: Action Button & Volume Buttons (Left Side)
          if (!_isLandscape) ...[
            Positioned(
              left: 10 - buttonThickness,
              top: 110,
              child: _buildHardwareButton(width: buttonThickness, height: 32),
            ),
            Positioned(
              left: 10 - buttonThickness,
              top: 156,
              child: _buildHardwareButton(width: buttonThickness, height: 58),
            ),
            Positioned(
              left: 10 - buttonThickness,
              top: 226,
              child: _buildHardwareButton(width: buttonThickness, height: 58),
            ),

            // Hardware Button: Power / Lock Button (Right Side)
            Positioned(
              right: 10 - buttonThickness,
              top: 168,
              child: _buildHardwareButton(width: buttonThickness, height: 86),
            ),
          ],

          // Outer Titanium / Space Black Frame
          Container(
            width: phoneOuterWidth,
            height: phoneOuterHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF1E212B),
              borderRadius: BorderRadius.circular(cornerRadius + bezelWidth),
              border: Border.all(
                color: const Color(0xFF383C4A),
                width: 2.5,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3A3E4E),
                  Color(0xFF1A1C24),
                  Color(0xFF161820),
                  Color(0xFF2C303E),
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(bezelWidth),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(cornerRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(cornerRadius - 2),
                child: Stack(
                  children: [
                    // The App Screen with simulated device MediaQuery
                    Positioned.fill(
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          size: deviceSize,
                          padding: safeArea,
                          viewPadding: safeArea,
                          viewInsets: EdgeInsets.zero,
                          devicePixelRatio: 3.0,
                        ),
                        child: widget.child,
                      ),
                    ),

                    // Dynamic Island (iPhone)
                    if (hasDynamicIsland && !_isLandscape)
                      Positioned(
                        top: 11,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 8),
                                // Front camera lens glint
                                Container(
                                  width: 11,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF0D1322),
                                    border: Border.all(
                                      color: const Color(0xFF1B2335),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Sensor reflection
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF090D18),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Punch-hole camera (Pixel)
                    if (!hasDynamicIsland && !_isLandscape)
                      Positioned(
                        top: 13,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              border: Border.all(
                                color: const Color(0xFF1E212B),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // iOS Home Indicator Pill at the bottom
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 134,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.38),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareButton({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2E323F),
        borderRadius: BorderRadius.horizontal(
          left: const Radius.circular(2),
          right: const Radius.circular(2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }
}

/// Subtle grid pattern for modern developer studio feel
class _StudioBackgroundPainter extends CustomPainter {
  final bool isDark;

  _StudioBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..style = PaintingStyle.fill;

    const spacing = 36.0;
    const dotRadius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
