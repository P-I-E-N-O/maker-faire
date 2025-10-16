import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget>
    with SingleTickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: state.startLocation,
                initialZoom: 11.0,
                onTap: (tapPosition, point) async {
                  // Set destination on tap with error handling
                  try {
                    await state.setDestination(point);
                  } catch (e) {
                    if (context.mounted) {
                      _showErrorDialog(context, e.toString());
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ripieno.app',
                ),

                // Route polylines
                if (state.destination != null)
                  Builder(
                    builder: (context) {
                      final optimized = state.optimizedRouteGeometry;
                      final direct = state.directRouteGeometry;
                      final hasOptimized =
                          optimized != null && optimized.isNotEmpty;
                      final hasDirect = direct != null && direct.isNotEmpty;

                      final polylines = <Polyline>[];

                      if (hasOptimized) {
                        if (hasDirect) {
                          polylines.add(
                            Polyline(
                              points: direct!,
                              strokeWidth: 3.0,
                              color: Colors.grey.withOpacity(0.45),
                            ),
                          );
                        }

                        polylines.add(
                          Polyline(
                            points: optimized!,
                            strokeWidth: 5.0,
                            color: Colors.blue,
                            borderStrokeWidth: 2.0,
                            borderColor: Colors.white,
                          ),
                        );
                      } else if (hasDirect) {
                        polylines.add(
                          Polyline(
                            points: direct!,
                            strokeWidth: 5.0,
                            color: Colors.blue,
                            borderStrokeWidth: 2.0,
                            borderColor: Colors.white,
                          ),
                        );
                      }

                      if (polylines.isEmpty) {
                        polylines.add(
                          Polyline(
                            points: [state.startLocation, state.destination!],
                            strokeWidth: 3.0,
                            color: Colors.grey.withOpacity(0.4),
                          ),
                        );

                        if (state.selectedStation != null) {
                          polylines.add(
                            Polyline(
                              points: [
                                state.startLocation,
                                state.selectedStation!.location,
                                state.destination!,
                              ],
                              strokeWidth: 4.0,
                              color: Colors.blue,
                              borderStrokeWidth: 2.0,
                              borderColor: Colors.white,
                            ),
                          );
                        }
                      }

                      return PolylineLayer(polylines: polylines);
                    },
                  ),

                // Markers layer
                MarkerLayer(
                  markers: [
                    // Starting point (Gazometro Ostiense - Maker Faire logo)
                    Marker(
                      point: state.startLocation,
                      width: 60,
                      height: 60,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withOpacity(0.3),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/maker-faire.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Destination marker
                    if (state.destination != null)
                      Marker(
                        point: state.destination!,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.home,
                          size: 50,
                          color: Colors.green,
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.black45),
                          ],
                        ),
                      ),

                    // Fuel stations markers
                    ...state.rankedStations.map((station) {
                      final isSelected =
                          state.selectedStation?.id == station.id;
                      return Marker(
                        point: station.location,
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            _showStationInfo(context, station);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? Colors.yellow : Colors.blue,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Colors.yellow.withOpacity(0.6)
                                      : Colors.blue.withOpacity(0.6),
                                  blurRadius: isSelected ? 15 : 8,
                                  spreadRadius: isSelected ? 3 : 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.local_gas_station,
                              color: Colors.white,
                              size: isSelected ? 28 : 24,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),

            // Loading overlay
            if (state.isCalculating)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Calculating optimal route...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Instruction overlay
            if (state.destination == null)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  color: Colors.white.withOpacity(0.95),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.touch_app, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tap on the map to set your destination',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showStationInfo(BuildContext context, FuelStation station) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(station.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.functions, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'K-Objective: ${station.objective.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Lower is better (K1*cost + K2*time)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.euro,
              'Price',
              '€${station.pricePerLiter.toStringAsFixed(3)}/L',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.payments,
              'Fuel Cost',
              '€${station.estimatedCost.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'Total Time',
              '${station.estimatedTime.toStringAsFixed(0)} min (+${station.extraTime.toStringAsFixed(1)} min detour)',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.route,
              'Total Distance',
              '${station.totalDistance.toStringAsFixed(1)} km (+${station.extraDistance.toStringAsFixed(1)} km detour)',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Failed to calculate route:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            const Text(
              'Please ensure:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Python API server is running on port 5321'),
            const Text('• GraphHopper API is accessible'),
            const Text('• Station data is loaded correctly'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
