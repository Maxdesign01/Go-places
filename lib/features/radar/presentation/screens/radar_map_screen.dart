import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/mock_data.dart';
import '../../../home/domain/models/place_model.dart';
import '../../../place_detail/presentation/screens/place_detail_screen.dart';

/// RadarMapScreen: Real Google Maps & Satellite integration
/// via high-resolution tile layers with custom editorial markers,
/// user GPS pulse, mood filters, and synchronized place carousel.
class RadarMapScreen extends StatefulWidget {
  const RadarMapScreen({super.key});

  @override
  State<RadarMapScreen> createState() => _RadarMapScreenState();
}

class _RadarMapScreenState extends State<RadarMapScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPlaceIndex = 0;
  String _selectedMoodFilter = 'all';
  String _mapLayer = 'google_streets'; // 'google_streets', 'google_satellite', 'editorial_warm'

  late final MapController _mapController;
  late final PageController _pageController;
  late final AnimationController _pulseController;

  static const LatLng _userLocation = LatLng(6.4281, 3.4219); // Victoria Island, Lagos

  List<PlaceModel> get _allPlaces => MockData.curatedPlaces;

  List<PlaceModel> get _filteredPlaces {
    if (_selectedMoodFilter == 'all') {
      return _allPlaces;
    }
    return _allPlaces
        .where((place) => place.mood == _selectedMoodFilter)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pageController = PageController(viewportFraction: 0.88);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String get _currentTileUrl {
    switch (_mapLayer) {
      case 'google_satellite':
        // Real Google Maps Satellite + Road Hybrid Layer
        return 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';
      case 'editorial_warm':
        // CartoDB Voyager (Warm editorial light design)
        return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png';
      case 'google_streets':
      default:
        // Real Google Maps Road & Street Layer
        return 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
    }
  }

  String get _mapLayerDisplayName {
    switch (_mapLayer) {
      case 'google_satellite':
        return 'Google Satellite';
      case 'editorial_warm':
        return 'Warm Editorial';
      case 'google_streets':
      default:
        return 'Google Maps';
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      (currentZoom + 1.0).clamp(11.0, 18.5),
    );
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      (currentZoom - 1.0).clamp(11.0, 18.5),
    );
  }

  void _recenterOnUser() {
    _mapController.move(_userLocation, 14.8);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Centered on your live location in Victoria Island'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1400),
      ),
    );
  }

  void _onPinTapped(int index, PlaceModel place) {
    setState(() {
      _selectedPlaceIndex = index;
    });

    _mapController.move(LatLng(place.latitude, place.longitude), 15.2);

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onCardPageChanged(int index, List<PlaceModel> places) {
    setState(() {
      _selectedPlaceIndex = index;
    });

    if (index < places.length) {
      final place = places[index];
      _mapController.move(LatLng(place.latitude, place.longitude), 15.0);
    }
  }

  void _cycleMapLayer() {
    setState(() {
      if (_mapLayer == 'google_streets') {
        _mapLayer = 'google_satellite';
      } else if (_mapLayer == 'google_satellite') {
        _mapLayer = 'editorial_warm';
      } else {
        _mapLayer = 'google_streets';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to $_mapLayerDisplayName mode'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = _filteredPlaces.isEmpty ? _allPlaces : _filteredPlaces;

    return Scaffold(
      backgroundColor: const Color(0xFFE5E3DF),
      body: Stack(
        children: [
          // 1. Real Google Maps FlutterMap Layer
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(6.4295, 3.4260),
              initialZoom: 14.4,
              minZoom: 10.0,
              maxZoom: 19.0,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _currentTileUrl,
                userAgentPackageName: 'com.goplaces.go_places',
                maxZoom: 19,
              ),

              // Markers Layer: User Location + Curated Places
              MarkerLayer(
                markers: [
                  // User Location with animated Radar Pulse
                  Marker(
                    point: _userLocation,
                    width: 140,
                    height: 140,
                    alignment: Alignment.center,
                    child: _buildUserLocationMarker(),
                  ),

                  // Real-Time Events Markers on Google Map
                  ...MockData.liveEvents.map((event) {
                    return Marker(
                      point: LatLng(event.latitude, event.longitude),
                      width: 140,
                      height: 64,
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          _mapController.move(
                            LatLng(event.latitude, event.longitude),
                            15.4,
                          );
                          _showEventSnippetModal(event);
                        },
                        child: _buildEventMapPin(event),
                      ),
                    );
                  }),

                  // Venue Pins
                  ...places.asMap().entries.map((entry) {
                    final index = entry.key;
                    final place = entry.value;
                    final isSelected = _selectedPlaceIndex == index;

                    return Marker(
                      point: LatLng(place.latitude, place.longitude),
                      width: isSelected ? 150 : 130,
                      height: isSelected ? 84 : 68,
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () => _onPinTapped(index, place),
                        child: _buildRichMapPin(place, isSelected),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // 2. Top Header Controls & Mood Filters
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Back Button
                      _buildGlassButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),

                      const SizedBox(width: 10),

                      // City & Map Mode Indicator
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.isDark
                                ? const Color(0xEE1A1D27)
                                : Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderHairline),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: AppColors.isDark ? 0.35 : 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.public_rounded,
                                  size: 16, color: AppColors.accentCoral),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Victoria Island • $_mapLayerDisplayName',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.statusLiveGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Recenter GPS Button
                      _buildGlassButton(
                        icon: Icons.my_location_rounded,
                        iconColor: AppColors.accentCoral,
                        onTap: _recenterOnUser,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Mood Filters Scrollable Pills
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: MockData.moods.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final mood = MockData.moods[index];
                        final isSelected = mood['id'] == _selectedMoodFilter;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMoodFilter = mood['id'] as String;
                              _selectedPlaceIndex = 0;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (AppColors.isDark
                                      ? Colors.white
                                      : const Color(0xFF121212))
                                  : (AppColors.isDark
                                      ? const Color(0xEE1A1D27)
                                      : Colors.white.withValues(alpha: 0.94)),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected
                                    ? (AppColors.isDark
                                        ? Colors.white
                                        : const Color(0xFF121212))
                                    : AppColors.borderHairline,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                      alpha: AppColors.isDark ? 0.2 : 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(mood['emoji'] as String,
                                    style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(
                                  mood['label'] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? (AppColors.isDark
                                            ? const Color(0xFF121212)
                                            : Colors.white)
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Right Floating Controls (Zoom +, Zoom -, Map Style Switcher)
          Positioned(
            right: 16,
            top: 140,
            child: Column(
              children: [
                // Zoom In
                _buildFloatingToolButton(
                  icon: Icons.add_rounded,
                  onTap: _zoomIn,
                  tooltip: 'Zoom In',
                ),
                const SizedBox(height: 8),
                // Zoom Out
                _buildFloatingToolButton(
                  icon: Icons.remove_rounded,
                  onTap: _zoomOut,
                  tooltip: 'Zoom Out',
                ),
                const SizedBox(height: 12),
                // Compass / Recenter North
                _buildFloatingToolButton(
                  icon: Icons.explore_rounded,
                  iconColor: AppColors.accentCoral,
                  onTap: () => _mapController.rotate(0),
                  tooltip: 'Reset North',
                ),
                const SizedBox(height: 12),
                // Map Layer Switcher (Google Street, Satellite, Warm)
                _buildFloatingToolButton(
                  icon: _mapLayer == 'google_satellite'
                      ? Icons.satellite_alt_rounded
                      : (_mapLayer == 'editorial_warm'
                          ? Icons.palette_outlined
                          : Icons.map_rounded),
                  iconColor: AppColors.accentCoral,
                  onTap: _cycleMapLayer,
                  tooltip: 'Switch Map Layer',
                ),
              ],
            ),
          ),

          // 4. Attribution / Map Source Tag
          Positioned(
            left: 16,
            bottom: 192,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.isDark
                    ? const Color(0xEE1A1D27)
                    : Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: Text(
                '© Google Maps • Live Radar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // 5. Bottom Horizontal Place Cards Carousel
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: places.length,
                onPageChanged: (index) => _onCardPageChanged(index, places),
                itemBuilder: (context, index) {
                  final place = places[index];
                  return _buildBottomPlaceCard(place);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserLocationMarker() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final progress = _pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer radar wave
            Container(
              width: 140 * progress,
              height: 140 * progress,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentCoral.withValues(
                    alpha: (1.0 - progress) * 0.7,
                  ),
                  width: 2,
                ),
              ),
            ),
            // Semi-transparent radar wave
            Container(
              width: 80 * progress,
              height: 80 * progress,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentCoral.withValues(
                  alpha: (1.0 - progress) * 0.25,
                ),
              ),
            ),
            // Live GPS Dot
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.accentCoral,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentCoral.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final effectiveColor = iconColor ?? AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.isDark
              ? const Color(0xEE1A1D27)
              : Colors.white.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderHairline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                  alpha: AppColors.isDark ? 0.35 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: effectiveColor),
      ),
    );
  }

  Widget _buildFloatingToolButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    Color? iconColor,
  }) {
    final effectiveColor = iconColor ?? AppColors.textPrimary;
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.isDark
                ? const Color(0xEE1A1D27)
                : Colors.white.withValues(alpha: 0.94),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderHairline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                    alpha: AppColors.isDark ? 0.35 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: effectiveColor),
        ),
      ),
    );
  }

  Widget _buildEventMapPin(EventModel event) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.statusLiveGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  event.title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFEA580C),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEA580C).withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_fire_department_rounded,
            size: 13,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showEventSnippetModal(EventModel event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Verified via ${event.source}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    event.ticketPrice,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentCoral,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                event.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${event.placeName} • ${event.venueAddress}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 14, color: AppColors.accentCoral),
                  const SizedBox(width: 5),
                  Text(
                    event.time,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.isDark
                          ? const Color(0xFF242836)
                          : const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${event.attendeesCount} Going',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRichMapPin(PlaceModel place, bool isSelected) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 240),
      scale: isSelected ? 1.08 : 0.94,
      curve: Curves.easeOutBack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Venue Title Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? (AppColors.isDark ? Colors.white : const Color(0xFF121212))
                  : (AppColors.isDark ? const Color(0xEE1A1D27) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (AppColors.isDark ? Colors.white : const Color(0xFF121212))
                    : AppColors.borderHairline,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(place.mood),
                  size: 12,
                  color: isSelected
                      ? (AppColors.isDark ? const Color(0xFF121212) : Colors.white)
                      : AppColors.accentCoral,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    place.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? (AppColors.isDark ? const Color(0xFF121212) : Colors.white)
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // Rating Circle Marker
          Container(
            padding: EdgeInsets.all(isSelected ? 8 : 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentCoral : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : AppColors.borderHairline,
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? AppColors.accentCoral : Colors.black)
                      .withValues(alpha: isSelected ? 0.45 : 0.18),
                  blurRadius: isSelected ? 12 : 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              '★ ${place.rating}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),

          // Downward pointer
          CustomPaint(
            size: const Size(8, 5),
            painter: _PinArrowPainter(
              color: isSelected ? AppColors.accentCoral : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String mood) {
    switch (mood) {
      case 'chill':
        return Icons.coffee_rounded;
      case 'party':
        return Icons.local_bar_rounded;
      case 'nature':
        return Icons.park_rounded;
      case 'learn':
        return Icons.lightbulb_rounded;
      case 'art':
        return Icons.palette_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Widget _buildBottomPlaceCard(PlaceModel place) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(place: place),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderHairline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 110,
                height: double.infinity,
                child: Image.network(
                  place.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceSubtle,
                    child: Icon(Icons.place, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          place.category.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentCoral,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 2),
                      Text(
                        place.rating.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '${place.distance} • ${place.crowdLevel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        place.openHours,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.statusLiveGreen,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'View',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Pin arrow pointer
class _PinArrowPainter extends CustomPainter {
  final Color color;

  const _PinArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
