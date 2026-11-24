import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/state/location_state.dart';
import '../../data/mock_data.dart';
import '../../domain/models/place_model.dart';
import '../widgets/curated_place_card.dart';
import '../widgets/floating_navbar.dart';
import '../widgets/live_events_carousel.dart';
import '../widgets/mood_selector.dart';
import '../widgets/state_selector_sheet.dart';
import '../../../place_detail/presentation/screens/place_detail_screen.dart';
import '../../../radar/presentation/screens/live_radar_screen.dart';
import '../../../radar/presentation/screens/radar_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedMood = 'all';
  int _navIndex = 0;
  final TextEditingController _promptController = TextEditingController();

  // Search & Filter state
  String _searchQuery = '';
  String _selectedPriceFilter = 'All'; // 'All', '$', '$$', '$$$'
  double _minRating = 0.0; // 0.0, 4.5, 4.8
  bool _onlyOpenNow = false;
  bool _onlyTrending = false;

  // Profile preferences state
  bool _radarAlertsEnabled = true;
  String _locationRadius = '5 km';
  String _curationVibeMode = 'AI Personalized';

  bool get _hasActiveFilters =>
      _selectedPriceFilter != 'All' ||
      _minRating > 0.0 ||
      _onlyOpenNow ||
      _onlyTrending;

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedPriceFilter != 'All') count++;
    if (_minRating > 0.0) count++;
    if (_onlyOpenNow) count++;
    if (_onlyTrending) count++;
    return count;
  }

  @override
  void initState() {
    super.initState();
    LocationStateNotifier.instance.addListener(_onLocationChanged);
  }

  void _onLocationChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    LocationStateNotifier.instance.removeListener(_onLocationChanged);
    _promptController.dispose();
    super.dispose();
  }

  List<PlaceModel> get _filteredPlaces {
    final stateId = LocationStateNotifier.instance.selectedStateId;
    return MockData.getPlacesForState(stateId).where((place) {
      // Mood filter
      if (_selectedMood != 'all' && place.mood != _selectedMood) {
        return false;
      }

      // Search text filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = place.name.toLowerCase().contains(query);
        final matchesCategory = place.category.toLowerCase().contains(query);
        final matchesVibe = place.aiVibeSummary.toLowerCase().contains(query);
        final matchesTags =
            place.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchesName && !matchesCategory && !matchesVibe && !matchesTags) {
          return false;
        }
      }

      // Price filter
      if (_selectedPriceFilter != 'All') {
        if (place.priceLevel.trim() != _selectedPriceFilter) {
          return false;
        }
      }

      // Rating filter
      if (_minRating > 0.0 && place.rating < _minRating) {
        return false;
      }

      // Trending filter
      if (_onlyTrending && !place.isTrending) {
        return false;
      }

      // Open hours filter
      if (_onlyOpenNow && !place.openHours.toLowerCase().contains('open')) {
        return false;
      }

      return true;
    }).toList();
  }

  void _onPlaceTap(PlaceModel place) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaceDetailScreen(place: place),
      ),
    );
  }

  void _onBookmark(PlaceModel place) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved "${place.name}" to your list!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
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
          body: Stack(
            children: [
              IndexedStack(
                index: _navIndex,
                children: [
                  _buildExploreView(),
                  const LiveRadarScreen(),
                  _buildSavedView(),
                  _buildProfileView(),
                ],
              ),

              // Floating Bottom Navigation Dock (styled after the reference image)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FloatingNavbar(
                  currentIndex: _navIndex,
                  onTap: (index) {
                    setState(() {
                      _navIndex = index;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 0: EXPLORE VIEW ---
  Widget _buildExploreView() {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Top Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: _buildTopHeader(),
            ),
          ),

          // 2. Greeting & Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey Sunday 👋',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Where to today?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // 3. Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(),
            ),
          ),

          if (_hasActiveFilters)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
                child: _buildActiveFilterRow(),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 4. Mood Filter Chips
          SliverToBoxAdapter(
            child: MoodSelector(
              selectedMoodId: _selectedMood,
              onMoodSelected: (id) {
                setState(() {
                  _selectedMood = id;
                });
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 5. Live Events Carousel (Happening Right Now)
          SliverToBoxAdapter(
            child: LiveEventsCarousel(
              events: MockData.getEventsForState(
                  LocationStateNotifier.instance.selectedStateId),
              onEventTap: (event) {
                setState(() {
                  _navIndex = 1; // Switch to Live Radar tab
                });
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // 6. Curated Places Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Curated For Your Mood',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '${_filteredPlaces.length} spots',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // 7. Curated Places List
          if (_filteredPlaces.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'No spots match your filters',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try searching for something else or clearing your filters',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _promptController.clear();
                            _searchQuery = '';
                            _selectedMood = 'all';
                            _selectedPriceFilter = 'All';
                            _minRating = 0.0;
                            _onlyOpenNow = false;
                            _onlyTrending = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reset Search & Filters',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final place = _filteredPlaces[index];
                    return CuratedPlaceCard(
                      place: place,
                      onTap: () => _onPlaceTap(place),
                      onBookmarkTap: () => _onBookmark(place),
                    );
                  },
                  childCount: _filteredPlaces.length,
                ),
              ),
            ),

          // Space for Floating Navbar
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // --- TAB 2: SAVED BUCKET LIST VIEW ---
  Widget _buildSavedView() {
    final stateId = LocationStateNotifier.instance.selectedStateId;
    final savedPlaces = MockData.getPlacesForState(stateId).take(3).toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Places',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your personal bucket list & spots you want to visit.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final place = savedPlaces[index];
                  return CuratedPlaceCard(
                    place: place,
                    onTap: () => _onPlaceTap(place),
                    onBookmarkTap: () => _onBookmark(place),
                  );
                },
                childCount: savedPlaces.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // --- TAB 3: USER PROFILE & VIBE SETTINGS VIEW ---
  Widget _buildProfileView() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Profile Header
            Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderHairline, width: 2),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sunday Chukwu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Product Designer & AI Engineer',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => StateSelectorBottomSheet.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '📍 ${LocationStateNotifier.instance.selectedPopularAreas.split(',').first.trim()}, ${LocationStateNotifier.instance.selectedStateName} ⌄',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Vibe Stats Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('14', 'Spots Visited'),
                  Container(width: 1, height: 32, color: AppColors.borderHairline),
                  _buildStatItem('6', 'Events RSVPed'),
                  Container(width: 1, height: 32, color: AppColors.borderHairline),
                  _buildStatItem('3', 'Saved Lists'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Favorite Moods Section
            Text(
              'My Go-To Vibes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildVibeTag('☕ Deep Work & Coffee'),
                _buildVibeTag('🪩 House & Vinyl Nights'),
                _buildVibeTag('💡 Tech & Product Meetups'),
                _buildVibeTag('🏕️ Nature Escapes'),
              ],
            ),

            const SizedBox(height: 28),

            // Appearance Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appearance',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  AppThemeNotifier.instance.isDark ? 'Dark Mode' : 'Light Mode',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentCoral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildThemeSwitcher(),

            const SizedBox(height: 28),

            // Preferences & Settings List
            Text(
              'Preferences',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Live Radar Alerts',
              subtitle: _radarAlertsEnabled
                  ? 'Push notifications enabled for nearby live events'
                  : 'Radar alerts are currently paused',
              trailing: Switch.adaptive(
                value: _radarAlertsEnabled,
                activeTrackColor: AppColors.accentCoral,
                onChanged: _toggleRadarAlerts,
              ),
              onTap: () => _toggleRadarAlerts(!_radarAlertsEnabled),
            ),
            _buildSettingsTile(
              icon: Icons.location_on_outlined,
              title: 'Location Precision',
              subtitle: 'Victoria Island ($_locationRadius radius)',
              onTap: _showLocationRadiusDialog,
            ),
            _buildSettingsTile(
              icon: Icons.tune_rounded,
              title: 'Vibe Curation Engine',
              subtitle: _curationVibeMode,
              onTap: _showCurationEngineDialog,
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.accentCoral,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVibeTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildThemeSwitcher() {
    final isDark = AppThemeNotifier.instance.isDark;

    return Row(
      children: [
        // Light Mode Option
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (isDark) {
                AppThemeNotifier.instance.setDarkMode(false);
                setState(() {});
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: !isDark
                    ? AppColors.accentCoral.withValues(alpha: 0.08)
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: !isDark
                      ? AppColors.accentCoral
                      : AppColors.borderHairline,
                  width: !isDark ? 1.6 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: !isDark ? 0.06 : 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.light_mode_rounded,
                    size: 19,
                    color: !isDark
                        ? AppColors.accentCoral
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Light Mode',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight:
                          !isDark ? FontWeight.w800 : FontWeight.w600,
                      color: !isDark
                          ? AppColors.accentCoral
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Dark Mode Option
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!isDark) {
                AppThemeNotifier.instance.setDarkMode(true);
                setState(() {});
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.accentCoral.withValues(alpha: 0.12)
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.accentCoral
                      : AppColors.borderHairline,
                  width: isDark ? 1.6 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.06 : 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dark_mode_rounded,
                    size: 19,
                    color: isDark
                        ? AppColors.accentCoral
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dark Mode',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight:
                          isDark ? FontWeight.w800 : FontWeight.w600,
                      color: isDark
                          ? AppColors.accentCoral
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderHairline),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _toggleRadarAlerts(bool value) {
    setState(() {
      _radarAlertsEnabled = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Radar Alerts enabled! You\'ll get notified when events start.'
              : 'Radar alerts paused.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: value ? AppColors.accentCoral : AppColors.textPrimary,
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  void _showLocationRadiusDialog() {
    final stateName = LocationStateNotifier.instance.selectedStateName;
    final radii = ['3 km', '5 km', '10 km', '25 km', 'Anywhere in $stateName'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Location Search Radius',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: radii.map((radius) {
              final isSelected = _locationRadius == radius;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _locationRadius = radius;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Search radius set to $radius'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.accentCoral,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentCoral.withValues(alpha: 0.08)
                        : AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentCoral
                          : AppColors.borderHairline,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        radius,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.accentCoral
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: AppColors.accentCoral,
                        )
                      else
                        Icon(
                          Icons.circle_outlined,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showCurationEngineDialog() {
    final modes = [
      {
        'name': 'AI Personalized',
        'desc': 'Tailored to your habits & saved vibes'
      },
      {
        'name': 'Trending First',
        'desc': 'Prioritizes viral check-ins and buzz'
      },
      {
        'name': 'Hidden Gems Only',
        'desc': 'Off-the-beaten-path cafes & rooftops'
      },
      {
        'name': 'Chill & Work',
        'desc': 'Quiet spaces, power outlets, great Wi-Fi'
      },
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Vibe Curation Engine',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: modes.map((mode) {
              final name = mode['name']!;
              final desc = mode['desc']!;
              final isSelected = _curationVibeMode == name;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _curationVibeMode = name;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Curation engine set to: $name'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.accentCoral,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentCoral.withValues(alpha: 0.08)
                        : AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentCoral
                          : AppColors.borderHairline,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.accentCoral
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              desc,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: AppColors.accentCoral,
                        )
                      else
                        Icon(
                          Icons.circle_outlined,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Location Pill (Tappable State Selector)
        GestureDetector(
          onTap: () => StateSelectorBottomSheet.show(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.borderHairline,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.accentCoral),
                const SizedBox(width: 6),
                Text(
                  LocationStateNotifier.instance.selectedDisplayName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),

        // Action Icons (Map View Button + Notification Bell + Profile Shortcut)
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RadarMapScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderHairline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_outlined, size: 16, color: AppColors.accentCoral),
                    const SizedBox(width: 5),
                    Text(
                      'Map',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderHairline,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      color: AppColors.textPrimary, size: 20),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.accentCoral,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  _navIndex = 3;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderHairline, width: 1.5),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: _searchQuery.isNotEmpty
              ? AppColors.accentCoral.withValues(alpha: 0.6)
              : AppColors.borderHairline,
          width: _searchQuery.isNotEmpty ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: _searchQuery.isNotEmpty
                ? AppColors.accentCoral
                : AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _promptController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: "Search places, vibes, coffee, rooftop...",
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_promptController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _promptController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _hasActiveFilters
                    ? AppColors.accentCoral
                    : AppColors.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: _hasActiveFilters
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                  if (_hasActiveFilters)
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          Text(
            'Filters:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          if (_selectedPriceFilter != 'All')
            _buildActiveFilterChip(
              label: 'Price: $_selectedPriceFilter',
              onDeleted: () => setState(() => _selectedPriceFilter = 'All'),
            ),
          if (_minRating > 0.0)
            _buildActiveFilterChip(
              label: '★ ${_minRating.toStringAsFixed(1)}+',
              onDeleted: () => setState(() => _minRating = 0.0),
            ),
          if (_onlyOpenNow)
            _buildActiveFilterChip(
              label: 'Open Now',
              onDeleted: () => setState(() => _onlyOpenNow = false),
            ),
          if (_onlyTrending)
            _buildActiveFilterChip(
              label: 'Trending',
              onDeleted: () => setState(() => _onlyTrending = false),
            ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPriceFilter = 'All';
                _minRating = 0.0;
                _onlyOpenNow = false;
                _onlyTrending = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'Clear all',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentCoral,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accentCoral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentCoral.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.accentCoral,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.accentCoral,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final activeCount = _activeFiltersCount;

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderHairline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filter & Preferences',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeCount > 0
                                  ? '$activeCount active filters applied'
                                  : 'Refine curated places',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (_hasActiveFilters)
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                _selectedPriceFilter = 'All';
                                _minRating = 0.0;
                                _onlyOpenNow = false;
                                _onlyTrending = false;
                              });
                              setState(() {});
                            },
                            child: Text(
                              'Reset All',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentCoral,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: AppColors.textPrimary),
                            onPressed: () => Navigator.pop(bottomSheetContext),
                          ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: AppColors.borderHairline),

                  // Scrollable Filter Options
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Section 1: Price Range
                        Text(
                          'Price Tier',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildFilterOptionChip(
                              label: 'All Prices',
                              isSelected: _selectedPriceFilter == 'All',
                              onTap: () {
                                setSheetState(() => _selectedPriceFilter = 'All');
                                setState(() {});
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterOptionChip(
                              label: r'$ Budget',
                              isSelected: _selectedPriceFilter == r'$',
                              onTap: () {
                                setSheetState(() => _selectedPriceFilter = r'$');
                                setState(() {});
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterOptionChip(
                              label: r'$$ Moderate',
                              isSelected: _selectedPriceFilter == r'$$',
                              onTap: () {
                                setSheetState(() => _selectedPriceFilter = r'$$');
                                setState(() {});
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterOptionChip(
                              label: r'$$$ Splurge',
                              isSelected: _selectedPriceFilter == r'$$$',
                              onTap: () {
                                setSheetState(() => _selectedPriceFilter = r'$$$');
                                setState(() {});
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Section 2: Rating
                        Text(
                          'Minimum Rating',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildFilterOptionChip(
                              label: 'Any Rating',
                              isSelected: _minRating == 0.0,
                              onTap: () {
                                setSheetState(() => _minRating = 0.0);
                                setState(() {});
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterOptionChip(
                              label: '★ 4.5+ Rated',
                              isSelected: _minRating == 4.5,
                              onTap: () {
                                setSheetState(() => _minRating = 4.5);
                                setState(() {});
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterOptionChip(
                              label: '★ 4.8+ Top Rated',
                              isSelected: _minRating == 4.8,
                              onTap: () {
                                setSheetState(() => _minRating = 4.8);
                                setState(() {});
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Section 3: Quick Toggles
                        Text(
                          'Venue Availability & Buzz',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderHairline),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile.adaptive(
                                title: Text(
                                  'Open Right Now',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  'Only show spots that are currently open today',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                value: _onlyOpenNow,
                                activeTrackColor: AppColors.accentCoral,
                                onChanged: (val) {
                                  setSheetState(() => _onlyOpenNow = val);
                                  setState(() {});
                                },
                              ),
                              Divider(height: 1, color: AppColors.borderHairline),
                              SwitchListTile.adaptive(
                                title: Text(
                                  'Trending & Hot Only',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  'Filter by spots with viral social momentum',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                value: _onlyTrending,
                                activeTrackColor: AppColors.accentCoral,
                                onChanged: (val) {
                                  setSheetState(() => _onlyTrending = val);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Apply Button
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      border: Border(
                        top: BorderSide(color: AppColors.borderHairline),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(bottomSheetContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentCoral,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Show ${_filteredPlaces.length} Results',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentCoral
                : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentCoral
                  : AppColors.borderHairline,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
