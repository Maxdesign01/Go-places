import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class CityStateModel {
  final String id;
  final String name;
  final String displayName;
  final String popularAreas;
  final LatLng centerCoordinates;
  final int spotsCount;
  final int eventsCount;
  final bool isDefault;

  const CityStateModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.popularAreas,
    required this.centerCoordinates,
    required this.spotsCount,
    required this.eventsCount,
    this.isDefault = false,
  });
}

class LocationStateNotifier extends ChangeNotifier {
  static final LocationStateNotifier instance = LocationStateNotifier._();
  LocationStateNotifier._();

  static const List<CityStateModel> availableStates = [
    CityStateModel(
      id: 'lagos',
      name: 'Lagos',
      displayName: 'Lagos, Nigeria',
      popularAreas: 'Victoria Island, Lekki, Ikoyi, Ikeja, Yaba',
      centerCoordinates: LatLng(6.4281, 3.4219),
      spotsCount: 18,
      eventsCount: 8,
      isDefault: true,
    ),
    CityStateModel(
      id: 'abuja',
      name: 'Abuja',
      displayName: 'Abuja, Nigeria',
      popularAreas: 'Maitama, Wuse 2, Jabi, Central Area, Garki',
      centerCoordinates: LatLng(9.0765, 7.3986),
      spotsCount: 12,
      eventsCount: 5,
    ),
    CityStateModel(
      id: 'rivers',
      name: 'Port Harcourt',
      displayName: 'Port Harcourt, NG',
      popularAreas: 'GRA Phase 2, Old GRA, Peter Odili, Trans Amadi',
      centerCoordinates: LatLng(4.8156, 7.0498),
      spotsCount: 9,
      eventsCount: 4,
    ),
    CityStateModel(
      id: 'oyo',
      name: 'Ibadan',
      displayName: 'Ibadan, Nigeria',
      popularAreas: 'Bodija, Ring Road, Jericho, UI Area, Oluyole',
      centerCoordinates: LatLng(7.3775, 3.9470),
      spotsCount: 8,
      eventsCount: 3,
    ),
    CityStateModel(
      id: 'enugu',
      name: 'Enugu',
      displayName: 'Enugu, Nigeria',
      popularAreas: 'Independence Layout, New Haven, GRA, Polo Park',
      centerCoordinates: LatLng(6.4584, 7.5464),
      spotsCount: 6,
      eventsCount: 2,
    ),
    CityStateModel(
      id: 'delta',
      name: 'Delta',
      displayName: 'Delta, Nigeria',
      popularAreas: 'Asaba GRA, Okpanam Road, Warri GRA, Effurun',
      centerCoordinates: LatLng(6.1984, 6.7329),
      spotsCount: 5,
      eventsCount: 2,
    ),
  ];

  // Default is always Lagos!
  CityStateModel _currentState = availableStates.first;

  CityStateModel get currentState => _currentState;
  String get selectedStateId => _currentState.id;
  String get selectedStateName => _currentState.name;
  String get selectedDisplayName => _currentState.displayName;
  String get selectedPopularAreas => _currentState.popularAreas;
  LatLng get selectedCoordinates => _currentState.centerCoordinates;

  void selectState(CityStateModel state) {
    if (_currentState.id != state.id) {
      _currentState = state;
      notifyListeners();
    }
  }

  void selectStateById(String id) {
    final match = availableStates.firstWhere(
      (s) => s.id == id,
      orElse: () => availableStates.first,
    );
    selectState(match);
  }
}
