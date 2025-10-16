# RI-PIENO Maker Faire Demo Setup

## 🎯 What Was Implemented

You now have a **complete integration** of the real RI-PIENO algorithm with the Flutter app:

### ✅ Python Backend API (`path-optimization/api_server.py`)
- **Real Italian fuel station database** (anagrafica_impianti_attivi.csv)
- **Real fuel prices** (prezzo_alle_8.csv)
- **Actual algorithm from main.py** with K-objective optimization
- **GraphHopper routing** (optional, works without API key)
- **Flask REST API** for Flutter to call

### ✅ Flutter Frontend (ripieno-app)
- **Beautiful UI** with RI-PIENO branding
- **Driver character cards** (Rezdora, Taxidora, Perezdora)
- **Interactive map** with route visualization
- **Real-time API calls** to Python backend
- **Automatic fallback** to mock data if API unavailable

### ✅ Algorithm Features
- **K-Objective function**: K1×Cost + K2×Time
- **Real fuel calculations** based on:
  - Car type (tank capacity: 35L/50L/80L)
  - Driver style (consumption: 6/7/9 L/100km)
  - Current fuel level
  - Distance and detours
- **Province filtering** (Rome area: RM, FR, LT)
- **Top 10 ranking** with detailed metrics

---

## 🚀 Running the Demo

### Step 1: Start Python Backend

**Terminal 1:**
```bash
cd /Users/carzacc/gits/path-optimization

# Optional: Set GraphHopper API key for real routing
# export GRAPHHOPPER_API_KEY="your_key_here"

# Start the API server
python api_server.py
```

**You should see:**
```
[INFO] Loading stations database...
[INFO] Loaded XXXX stations
[INFO] Loading fuel prices...
[INFO] Loaded XXXX price entries
[INFO] Starting RI-PIENO API server on port 5321...
```

**Verify it's running:**
```bash
curl http://localhost:5321/health
```

### Step 2: Start Flutter App

**Terminal 2:**
```bash
cd /Users/carzacc/gits/ripieno-app

# Run on Chrome (best for Maker Faire demo on a laptop)
flutter run -d chrome

# OR run on Android device
flutter run -d <device_id>

# OR run on iOS simulator
flutter run -d iPhone
```

---

## 🎪 Demo Flow for Maker Faire

### 1. **Welcome Screen**
- Show the RI-PIENO logo at top
- Explain: "Smart fuel station finder using optimization algorithms"

### 2. **Select Vehicle & Driver**
- **Car Type**: Small (efficient) → Family (balanced) → Supercar (thirsty)
  - Color coded: 🟢 Green → 🟡 Yellow → 🔴 Red
- **Driver Style**: Choose character:
  - 🟢 **Pina Rezdora** (Safe) - 6 L/100km
  - 🟡 **Ambrosia Tassìdora** (Average) - 7 L/100km
  - 🔴 **Sergina Perezdora** (Sporty) - 9 L/100km

### 3. **Set Fuel Level**
- Slide to show current fuel (e.g., 30%)
- Visual fuel gauge updates

### 4. **Pick Destination**
- **Tap anywhere on the map** to set destination
- Map shows:
  - 📍 **Maker Faire logo** = Starting point (Gazometro Ostiense)
  - 🏠 **Home icon** = Your destination
  - 🛣️ **Gray line** = Direct route
  - 🔵 **Blue line** = Optimized route through best station
  - ⛽ **Blue markers** = Available fuel stations
  - ⭐ **Yellow marker** = Best station (selected by algorithm)

### 5. **See Results**
- **Loading animation** (calling real algorithm!)
- **Best station highlighted** on map
- Click **"View Full Ranking"** button to see:
  - Top 10 stations
  - **K-Objective** scores (lower = better)
  - Cost, time, distance for each
  - Algorithm explanation

### 6. **Explain the Algorithm** 
Point to the info box:
```
K-Objective = K1×Cost + K2×Time

Lower is better! Considers:
• Fuel cost (consumption × price)
• Detour distance and time
• Tank capacity and current fuel
• Car type efficiency
• Driving style consumption
```

---

## 🔧 Technical Details

### API Communication
```
Flutter App (localhost) → HTTP POST → Python API (localhost:5321)
                       ← JSON Response ←
```

### Request Example:
```json
{
  "start": {"lat": 41.8719, "lon": 12.4784},
  "destination": {"lat": 41.9, "lon": 12.5},
  "car_type": "family",
  "driver_type": "average",
  "fuel_level": 0.3,
  "provinces": ["RM", "FR", "LT"]
}
```

### Response Example:
```json
{
  "success": true,
  "best_station": {
    "name": "Q8 Via Cristoforo Colombo",
    "price_per_liter": 1.749,
    "estimated_cost": 28.50,
    "estimated_time": 45.2,
    "objective": 73.7
  },
  "ranked_stations": [...]
}
```

---

## 🛠️ Troubleshooting

### Python Backend Issues

**"ModuleNotFoundError: No module named 'flask'"**
```bash
cd /Users/carzacc/gits/path-optimization
pip install -r requirements.txt
```

**"No stations found"**
- Check CSV files exist in path-optimization directory
- Try wider province filter: `["RM", "FR", "LT", "VT"]`

**"GraphHopper API error"**
- Server works without API key (uses simplified routing)
- Optional: Get free key at https://www.graphhopper.com/

### Flutter App Issues

**"Failed to connect to backend"**
- Verify Python server is running: `curl http://localhost:5321/health`
- Check Flutter console for error messages
- App will automatically use fallback mock data

**"CORS error"**
- Restart both servers
- flask-cors should handle this automatically

**"Map not loading"**
- Check internet connection (map tiles from OpenStreetMap)
- Wait a few seconds for tiles to load

---

## 🎨 Customization for Demo

### Change Starting Location
Edit `lib/models/app_state.dart`:
```dart
final LatLng startLocation = LatLng(41.8719, 12.4784); // Gazometro Ostiense
```

### Change Province Filter
Edit `lib/models/app_state.dart` in the API call:
```dart
'provinces': ['RM', 'FR', 'LT'], // Add more provinces
```

### Adjust Algorithm Weights
Edit the API call:
```dart
'k1': 1.0,  // Cost weight (increase to favor cheaper stations)
'k2': 1.0,  // Time weight (increase to favor closer stations)
```

---

## 📊 What Makes This Real

1. ✅ **Real Italian fuel stations** from government database
2. ✅ **Real fuel prices** (Gasolio/diesel prices)
3. ✅ **Actual distance calculations** (GraphHopper or Haversine)
4. ✅ **True fuel physics** (tank capacity, consumption rates)
5. ✅ **K-objective optimization** from research algorithm
6. ✅ **Detour analysis** (shows extra km and minutes)

---

## 🎯 Key Talking Points for Maker Faire

1. **"This uses REAL Italian fuel station data"**
   - Not random/fake stations
   - Actual locations from government database

2. **"The algorithm optimizes for BOTH cost AND time"**
   - Not just "cheapest" or "closest"
   - Balances trade-offs using K-objective function

3. **"It considers YOUR specific car and driving style"**
   - Different tank sizes
   - Different consumption rates
   - Real fuel physics

4. **"Built with Flutter for beautiful cross-platform UI"**
   - Same code runs on Web, iOS, Android
   - Python backend handles complex calculations

5. **"Open to contributions and improvements!"**
   - Can add GraphHopper for real routing
   - Can expand to other countries
   - Can add more optimization criteria

---

## 📝 Future Enhancements (Post-Maker Faire)

- [ ] GraphHopper API integration for real road routing
- [ ] Multiple waypoints (A → B → C → D)
- [ ] Save favorite routes
- [ ] Price history and trends
- [ ] Gas vs Diesel fuel type selection
- [ ] Offline mode with cached data
- [ ] Route replay/animation
- [ ] Share routes with friends

---

## 📧 Contact & Credits

**Algorithm**: Original Python implementation in `main.py`
**API Wrapper**: Flask REST API in `api_server.py`
**Flutter App**: Beautiful UI showcasing the algorithm
**Data**: Italian fuel stations (MISE) and prices

**For the Maker Faire Rome demo - Buona fortuna! 🚗⛽🇮🇹**

