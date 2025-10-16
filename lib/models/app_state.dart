import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum CarType { supercar, family, small }

enum DriverType { safe, average, sporty }

class FuelStation {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final double pricePerLiter;
  final double estimatedTime; // in minutes
  final double estimatedCost; // in euros
  final double totalDistance; // in km
  final double objective; // K1*cost + K2*time (lower is better)
  final double extraDistance; // km detour
  final double extraTime; // minutes detour

  FuelStation({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.pricePerLiter,
    required this.estimatedTime,
    required this.estimatedCost,
    required this.totalDistance,
    required this.objective,
    required this.extraDistance,
    required this.extraTime,
  });
}

class AppState extends ChangeNotifier {
  // API configuration
  static const String apiBaseUrl = 'http://localhost:5321';

  // Gazometro Ostiense coordinates
  final LatLng startLocation = LatLng(41.8719, 12.4784);

  LatLng? _destination;
  CarType _carType = CarType.family;
  DriverType _driverType = DriverType.average;
  double _fuelLevel = 0.3; // 30% full

  FuelStation? _selectedStation;
  List<FuelStation> _rankedStations = [];
  bool _isCalculating = false;
  List<LatLng>? _optimizedRouteGeometry; // Optimized route via selected station
  List<LatLng>? _directRouteGeometry; // Direct route without stops
  double _maxStationDistanceM = 2000.0;
  int? _maxRankedStations;
  Map<String, dynamic>? _lastMetadata;

  // Getters
  LatLng? get destination => _destination;
  CarType get carType => _carType;
  DriverType get driverType => _driverType;
  double get fuelLevel => _fuelLevel;
  FuelStation? get selectedStation => _selectedStation;
  List<FuelStation> get rankedStations => _rankedStations;
  bool get isCalculating => _isCalculating;
  List<LatLng>? get optimizedRouteGeometry => _optimizedRouteGeometry;
  List<LatLng>? get directRouteGeometry => _directRouteGeometry;
  double get maxStationDistanceM => _maxStationDistanceM;
  int? get maxRankedStations => _maxRankedStations;
  Map<String, dynamic>? get lastMetadata => _lastMetadata;

  // Backwards compatibility getter (used in older widgets)
  List<LatLng>? get routeGeometry => _optimizedRouteGeometry;

  // Tank capacity based on car type (in liters)
  double get tankCapacity {
    switch (_carType) {
      case CarType.supercar:
        return 80.0;
      case CarType.family:
        return 50.0;
      case CarType.small:
        return 35.0;
    }
  }

  // Fuel consumption based on driver type (L/100km)
  double get fuelConsumption {
    double baseConsumption;
    switch (_carType) {
      case CarType.supercar:
        baseConsumption = 15.0;
        break;
      case CarType.family:
        baseConsumption = 7.0;
        break;
      case CarType.small:
        baseConsumption = 5.0;
        break;
    }

    switch (_driverType) {
      case DriverType.safe:
        return baseConsumption * 0.9;
      case DriverType.average:
        return baseConsumption;
      case DriverType.sporty:
        return baseConsumption * 1.2;
    }
  }

  // Setters
  Future<void> setDestination(LatLng? location) async {
    _destination = location;
    notifyListeners();
    if (location != null) {
      await _calculateRoute();
    }
  }

  void setCarType(CarType type) {
    _carType = type;
    notifyListeners();
    if (_destination != null) {
      _calculateRoute();
    }
  }

  void setDriverType(DriverType type) {
    _driverType = type;
    notifyListeners();
    if (_destination != null) {
      _calculateRoute();
    }
  }

  void setFuelLevel(double level) {
    _fuelLevel = level.clamp(0.0, 1.0);
    notifyListeners();
    if (_destination != null) {
      _calculateRoute();
    }
  }

  void setMaxStationDistance(double meters) {
    _maxStationDistanceM = meters.clamp(100.0, 10000.0);
    notifyListeners();
    if (_destination != null) {
      _calculateRoute();
    }
  }

  void setMaxRankedStations(int? limit) {
    _maxRankedStations = limit != null && limit > 0 ? limit : null;
    notifyListeners();
    if (_destination != null) {
      _calculateRoute();
    }
  }

  // Calculate optimal route and fuel station using Python backend
  Future<void> _calculateRoute() async {
    if (_destination == null) return;

    _isCalculating = true;
    _optimizedRouteGeometry = null;
    _directRouteGeometry = null;
    _selectedStation = null;
    _rankedStations = [];
    _lastMetadata = null;
    notifyListeners();

    try {
      // Call Python backend API
      final response = await http.post(
        Uri.parse('$apiBaseUrl/optimize'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'start': {
            'lat': startLocation.latitude,
            'lon': startLocation.longitude,
          },
          'destination': {
            'lat': _destination!.latitude,
            'lon': _destination!.longitude,
          },
          'car_type': _carType.name,
          'driver_type': _driverType.name,
          'fuel_level': _fuelLevel,
          'provinces': ['RM', 'FR', 'LT'], // Rome area provinces
          'max_station_distance_m': _maxStationDistanceM,
          'max_ranked_stations': _maxRankedStations,
          'k1': 1.0,
          'k2': 1.0,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // Parse ranked stations from API response
          _rankedStations = (data['ranked_stations'] as List)
              .map(
                (station) => FuelStation(
                  id: station['id'],
                  name: station['name'],
                  address: station['address'] ?? 'Address unavailable',
                  location: LatLng(station['lat'], station['lon']),
                  pricePerLiter: station['price_per_liter'],
                  estimatedTime: station['estimated_time'],
                  estimatedCost: station['estimated_cost'],
                  totalDistance: station['total_distance'],
                  objective: station['objective'],
                  extraDistance: station['extra_distance'],
                  extraTime: station['extra_time'],
                ),
              )
              .toList();

          // Parse route geometry from GraphHopper
          _optimizedRouteGeometry = _parseGeometry(
            data['optimized_route_geometry'] ?? data['route_geometry'],
            label: 'optimized',
          );
          _directRouteGeometry = _parseGeometry(
            data['direct_route_geometry'],
            label: 'direct',
          );

          _lastMetadata = data['metadata'] as Map<String, dynamic>?;

          debugPrint(
            'ℹ️ Geometry summary: '
            'optimized=${_optimizedRouteGeometry?.length ?? 0} points, '
            'direct=${_directRouteGeometry?.length ?? 0} points',
          );

          // Select best station
          if (_rankedStations.isNotEmpty) {
            _selectedStation = _rankedStations.first;
          }

          debugPrint(
            '✅ Loaded ${_rankedStations.length} REAL stations from API!',
          );

          _isCalculating = false;
          notifyListeners();
        } else {
          final error = data['error'] ?? 'Unknown error';
          debugPrint('❌ API error: $error');
          _isCalculating = false;
          notifyListeners();
          throw Exception('API Error: $error');
        }
      } else {
        debugPrint('❌ HTTP error ${response.statusCode}: ${response.body}');
        _isCalculating = false;
        notifyListeners();
        throw Exception('HTTP ${response.statusCode}: Server error');
      }
    } catch (e) {
      debugPrint('❌ Fatal error calling API: $e');
      _isCalculating = false;
      notifyListeners();
      rethrow; // Re-throw to be caught by UI
    }
  }

  List<LatLng>? _parseGeometry(dynamic geometry, {required String label}) {
    if (geometry == null) {
      debugPrint('⚠️ No $label route geometry provided');
      return null;
    }

    if (geometry is! List) {
      debugPrint(
        '⚠️ Unexpected $label route geometry format: ${geometry.runtimeType}',
      );
      return null;
    }

    final rawPoints = geometry as List;
    final parsedPoints = <LatLng>[];

    for (final point in rawPoints) {
      if (point is Map) {
        final lat = point['lat'];
        final lon = point['lon'];
        if (lat is num && lon is num) {
          parsedPoints.add(LatLng(lat.toDouble(), lon.toDouble()));
        }
      }
    }

    if (parsedPoints.isEmpty) {
      debugPrint(
        '⚠️ $label route geometry contained no valid points '
        '(raw count: ${rawPoints.length})',
      );
      return null;
    }

    debugPrint(
      '✅ Loaded $label route geometry with ${parsedPoints.length} points',
    );
    return parsedPoints;
  }
}
