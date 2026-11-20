import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../widgets/auth_buttons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<EditorialSlideData> _slides = const [
    EditorialSlideData(
      categoryBadge: 'MOOD CURATION',
      title: 'Discover places that match your current vibe.',
      subtitle:
          'From quiet sunlit cafes to deep reading lofts and underground DJ sets—find the right spot for right now.',
      imageUrl:
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
      floatingTag: '☕ Quiet Loft • Open Now',
    ),
    EditorialSlideData(
      categoryBadge: 'LIVE RADAR',
      title: "Real-time updates on what's popping nearby.",
      subtitle:
          'Spontaneous rooftop sessions, tech meetups, art pop-ups, and live events happening within minutes of you.',
      imageUrl:
          'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?auto=format&fit=crop&w=800&q=80',
      floatingTag: '🔥 Rooftop Session • 0.8 km',
    ),
    EditorialSlideData(
      categoryBadge: 'SPONTANEOUS PLANS',
      title: "Never wonder where to spend your weekend.",
      subtitle:
          'Crowd levels, live atmospheres, and curated escapes tailored to your headspace.',
      imageUrl:
          'https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=800&q=80',
      floatingTag: '✨ 28 People Going',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppThemeNotifier.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgCanvas,
          body: SafeArea(
            child: Column(
              children: [
                // Top Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return _buildSlideContent(slide);
                    },
                  ),
                ),

                // Page Indicator Dots
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => _buildIndicatorDot(isActive: index == _currentPage),
                    ),
                  ),
                ),

                // Bottom Auth Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: AuthButtons(
                    onGooglePressed: _navigateToHome,
                    onApplePressed: _navigateToHome,
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlideContent(EditorialSlideData slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Hero Photography Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        slide.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceSubtle,
                          child: Center(
                            child: Icon(Icons.photo,
                                size: 48, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Floating Tag Pill on Image
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.isDark
                            ? const Color(0xEE1A1D27)
                            : Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.isDark
                              ? const Color(0xFF2E3345)
                              : Colors.transparent,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                                alpha: AppColors.isDark ? 0.35 : 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        slide.floatingTag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Title (Confident, no shouting kicker)
          Text(
            slide.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.25,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle
          Text(
            slide.subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIndicatorDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 24 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.textPrimary : AppColors.borderStrong,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class EditorialSlideData {
  final String categoryBadge;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String floatingTag;

  const EditorialSlideData({
    required this.categoryBadge,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.floatingTag,
  });
}
