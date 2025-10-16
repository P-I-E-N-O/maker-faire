import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class ControlsPanel extends StatelessWidget {
  const ControlsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Consumer<AppState>(
        builder: (context, state, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Car Type Selector
                const Text(
                  'Car Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildCarTypeSelector(context, state),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Driver Type Selector
                const Text(
                  'Driver Style',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildDriverTypeSelector(context, state),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Fuel Gauge
                const Text(
                  'Current Fuel Level',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildFuelGauge(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarTypeSelector(BuildContext context, AppState state) {
    return Row(
      children: const [
        _CarOption(
          type: CarType.small,
          imagePath: 'assets/citycar.png',
          label: 'City',
          color: Colors.green,
        ),
        _CarOption(
          type: CarType.family,
          imagePath: 'assets/familycar.png',
          label: 'Family',
          color: Color(0xFFFBC02D),
        ),
        _CarOption(
          type: CarType.supercar,
          imagePath: 'assets/sportscar.png',
          label: 'Sport',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildDriverTypeSelector(BuildContext context, AppState state) {
    return Column(
      children: [
        _buildDriverCard(
          context,
          state,
          DriverType.safe,
          'Mariapina Rezdora',
          'Safe Driver',
          'assets/Rezdora.png',
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildDriverCard(
          context,
          state,
          DriverType.average,
          'Ambrosia Tassìdora',
          'Average Driver',
          'assets/Taxidora.png',
          Colors.yellow.shade700,
        ),
        const SizedBox(height: 12),
        _buildDriverCard(
          context,
          state,
          DriverType.sporty,
          'Sergina Perezdora',
          'Sporty Driver',
          'assets/Sergio Perezdora.png',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildDriverCard(
    BuildContext context,
    AppState state,
    DriverType type,
    String name,
    String label,
    String imagePath,
    Color color,
  ) {
    final isSelected = state.driverType == type;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: () => state.setDriverType(type),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // SVG Character
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 16),
              // Text info
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : Colors.grey[700],
                  ),
                ),
              ),
              // Checkmark
              if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuelGauge(BuildContext context, AppState state) {
    return Column(
      children: [
        // Visual fuel gauge
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.grey[200]!, Colors.grey[100]!],
                  ),
                ),
              ),
              // Fuel level
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 150 * state.fuelLevel,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        _getFuelColor(state.fuelLevel),
                        _getFuelColor(state.fuelLevel).withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Percentage text
              Center(
                child: Text(
                  '${(state.fuelLevel * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    shadows: [Shadow(color: Colors.white, blurRadius: 4)],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Slider
        Slider(
          value: state.fuelLevel,
          onChanged: (value) => state.setFuelLevel(value),
          activeColor: _getFuelColor(state.fuelLevel),
          // label: '${(state.fuelLevel * 100).toInt()}%',
          divisions: 20,
        ),

        // Fuel info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Empty',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Full',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Color _getFuelColor(double level) {
    if (level < 0.25) {
      return Colors.red;
    } else if (level < 0.5) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}

class _CarOption extends StatelessWidget {
  const _CarOption({
    required this.type,
    required this.imagePath,
    required this.label,
    required this.color,
  });

  final CarType type;
  final String imagePath;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<AppState>(
        builder: (context, state, child) {
          final isSelected = state.carType == type;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () => state.setCarType(type),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.18) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey[300]!,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.28),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: isSelected ? 70 : 64,
                      width: double.infinity,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.15)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(imagePath, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? color : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
