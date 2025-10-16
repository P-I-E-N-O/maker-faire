# RI-PIENO - Maker Faire Demo App

## Overview
RI-PIENO is an intelligent fuel station recommendation app that helps drivers find the optimal fuel station along their route. The app showcases a sophisticated route optimization algorithm that considers multiple factors including fuel prices, distance, detour time, and vehicle characteristics.

## Features

### 1. Interactive Map
- **Starting Point**: Gazometro Ostiense (Maker Faire location) marked with the Maker Faire logo
- **Destination Selection**: Tap anywhere on the map to set your destination (marked with a home icon)
- **Fuel Station Markers**: Shows all ranked fuel stations with interactive markers
- **Optimal Station**: Highlighted in yellow with pulsing animation

### 2. Vehicle Configuration
- **Car Type Selector**: Choose between:
  - **Small Car**: 35L tank, 5 L/100km base consumption
  - **Family Car**: 50L tank, 7 L/100km base consumption  
  - **Supercar**: 80L tank, 15 L/100km base consumption

### 3. Driver Style Selector
Adjusts fuel consumption based on driving style:
- **Safe**: -10% consumption
- **Average**: Standard consumption
- **Sporty**: +20% consumption

### 4. Fuel Gauge
- Visual fuel level indicator with color coding:
  - Red: < 25%
  - Orange: 25-50%
  - Green: > 50%
- Interactive slider to set current fuel level
- Real-time fuel amount display in liters

### 5. Ranking System
- View full ranking of all fuel stations
- Stations ranked by comprehensive score considering:
  - Price per liter
  - Distance from route
  - Detour time
  - Current fuel level
  - Tank capacity

## How to Use

### For the Demo at Maker Faire:

1. **Set Vehicle Configuration**
   - Choose a car type (show how different cars have different parameters)
   - Select a driver style (demonstrate consumption changes)
   - Adjust the fuel gauge to simulate different scenarios

2. **Select Destination**
   - Tap on the map to set a destination
   - Watch the algorithm calculate the optimal route
   - Observe the fuel station markers appear

3. **Explore Results**
   - The optimal station is highlighted in yellow
   - Tap on any station marker to see details
   - Click "View Ranking" button to see the full ranking

4. **Interactive Demo Scenarios**:
   - **Low Fuel Scenario**: Set fuel to 10%, show how urgent stations are prioritized
   - **Long Distance**: Set far destination, show route optimization
   - **Car Comparison**: Switch between car types to show different recommendations
   - **Driver Style Impact**: Change driver style to show consumption effects

## Technical Details

### Architecture
- **State Management**: Provider pattern for reactive UI updates
- **Map Integration**: OpenStreetMap via flutter_map package
- **Animations**: Smooth transitions and pulsing markers for better UX
- **Responsive Design**: Adapts to different screen sizes

### Algorithm (Simplified for Demo)
The app demonstrates a simplified version of the Python algorithm from `path-optimization/main.py`:

```dart
Score = K1 * (price_factor) + K2 * (time_factor) + K3 * (distance_factor)
```

Factors considered:
- Fuel price per liter
- Detour time from optimal route
- Distance from main route
- Current fuel level vs tank capacity
- Vehicle consumption rate

### Future Enhancements
- Real-time fuel prices via API
- GraphHopper routing integration
- Historical price trends
- User preferences and favorites
- Multiple route alternatives

## Running the App

```bash
cd ripieno-app
flutter pub get
flutter run
```

### Requirements
- Flutter SDK 3.9.2 or higher
- Dart 3.0 or higher
- Internet connection for map tiles

## Demo Tips for Maker Faire

1. **Start with Default Settings**: Begin with family car, average driver, 30% fuel
2. **Show Interactivity**: Demonstrate tapping on map, changing settings
3. **Explain the Algorithm**: Use the ranking dialog to explain scoring
4. **Real-World Scenarios**: 
   - "Almost empty tank" scenario
   - "Long road trip" scenario
   - "Supercar vs small car" comparison
5. **Visual Elements**: Point out animations, color coding, icons
6. **User Benefits**: Emphasize time and money savings

## Customization for Production

To connect to the actual Python backend:
1. Deploy the Python algorithm as a REST API
2. Update `AppState._calculateRoute()` to call the API
3. Parse real fuel station data from the response
4. Integrate with real-time pricing services

## Contact

For questions about the algorithm or app, contact the development team.

---
*Built for Maker Faire Rome 2025*

