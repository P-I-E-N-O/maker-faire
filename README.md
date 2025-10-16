# RI-PIENO: Refueling Itinerary Optimization

## Overview
RI-PIENO (Revised and Improved Petrol-Filling Itinerary Estimation aNd Optimization) is a cost- and time-aware refueling itinerary optimizer. It extends the original PIENO proof of concept by embedding user-centric mobility modeling, delivering refueling recommendations that align with a driver’s habitual routes while minimizing travel time and fuel expenditure.

The framework combines in-vehicle telemetry, public fuel price data, predictive modeling, and route optimization to generate actionable refueling plans. By detailing the full workflow—from raw CAN Bus signals to high-level recommendations—RI-PIENO provides a reproducible foundation for further research and deployment.

## Key Capabilities
- Captures fuel-level telemetry via a CAN Access Module (CAM) based on ESP32 hardware
- Detects vehicle stops and promotes recurring locations to Points of Interest (POIs)
- Builds daily trip graphs that encode mobility patterns and visit frequency
- Forecasts weekly mileage through an ensemble of predictive models
- Optimizes refueling stops using OSRM routing, fuel price forecasts, and user mobility data
- Balances cost and travel time through tunable weights (`K1`, `K2`)

## System Architecture
RI-PIENO augments PIENO’s modular design with mobility awareness:

1. **CAN Access Module (CAM)** reads vehicle CAN Bus traffic, isolates the fuel-level signal, and detects ignition-off events indicative of stops. The approach is resilient to OEM-specific Signal ID mappings by correlating fuel gauge behavior with observed messages.
2. **Mobile Application** aggregates CAM telemetry, government-provided fuel station data, and Prophet-based fuel price forecasts, acting as the central user-facing hub.
3. **Optimization Engine** merges Daily Trip Graphs, Weekly Mileage Predictions, and OSRM routing results to generate refueling guidance tuned for cost and time.

## Workflow
The operational pipeline makes the sequence of transformations explicit:

1. **Data Acquisition** – The CAM streams CAN Bus data, extracting fuel-level readings and monitoring message silence to mark stop events.
2. **Stop Detection & Enrichment** – Each stop becomes a candidate POI with metadata: unique ID, coordinates (clustered under a configurable radius), visit counters, frequency buckets, auto-generated labels, and day-of-week occurrence.
3. **POI Promotion** – Candidate stops recurring at least twice per week (MEDIUM frequency) are promoted to POIs.
4. **Daily Trip Graph Construction** – Temporal ordering of POIs forms directed graphs that capture recurrent mobility flows.
5. **Weekly Mileage Prediction** – An ensemble forecasts mileage, providing anticipatory input for refueling range planning.
6. **Fuel Stop Optimization** – The optimizer combines POI flows, mileage forecasts, OSRM routes, government price feeds, and Prophet price trends. Adjustable constants `K1` (time) and `K2` (cost) tune trade-offs.
7. **Recommendation Delivery** – The mobile app surfaces the recommended station and route, keeping the driver in the loop.

## Core Components
- **Daily Trip Graph** – Identifies frequent POIs and reconstructs daily mobility flows, enabling context-aware route suggestions.
- **Weekly Mileage Prediction** – Estimates future mileage to anticipate refueling needs before the tank reaches critical levels.
- **Fuel Stop Optimization** – Integrates POIs, predictive insights, and routing to suggest stops aligned with user habits while minimizing cost and detours.

## Data Sources & Integrations
- **CAN Bus Telemetry** – Fuel level and stop detection.
- **Government Fuel Price Dataset** – Official Italian fuel price archives (`mimit.gov.it`).
- **OSRM** – Open-source routing engine for travel time and path estimation.
- **Meta Prophet** – Time-series forecasting for fuel price trends.
- **Flutter Mobile App** – User interface for recommendations and status monitoring.

## Evaluation Snapshot
Validation across 15 itineraries from three users demonstrates improvements over both the baseline (nearest station) and the original PIENO framework:

| Approach   | Cost [€] (↓)       | Time [min] (↓)     |
|------------|--------------------|---------------------|
| Baseline   | 44.53 ± 2.20       | 6.61 ± 1.01         |
| PIENO      | 43.24 ± 2.09       | 7.10 ± 2.23         |
| RI-PIENO   | **43.01 ± 2.13**   | **4.98 ± 0.80**     |

## Getting Started
- Install Flutter and set up your development environment.
- Clone the repository and connect the mobile app to the CAM hardware.
- Configure OSRM and the data ingestion pipelines (fuel price feeds, Prophet forecasts).
- Run the app on a physical device to access CAN Bus telemetry via the CAM.

## Future Directions
- Extend mobility modeling to multi-day trips and long-haul scenarios.
- Incorporate real-time V2X data for cooperative fleet optimization.
- Automate OEM-specific Signal ID mapping through collective datasets.
- Expand validation with larger user cohorts and diverse vehicle models.

## Acknowledgment
This work is partially supported by MOST – Sustainable Mobility National Research Center and received funding from the European Union Next-GenerationEU (PNRR – Missione 4 Componente 2, Investimento 1.4 – D.D. 1033 17/06/2022, CN00000023).

## References
1. R. Bosch GmbH. *CAN Specification Version 2.0*. 1991.
2. Espressif Systems. *ESP32 Series Datasheet*. 2023.
3. Luxen, D., & Vetter, C. “Real-time routing with OpenStreetMap data.” ACM SIGSPATIAL GIS, 2011.
4. SAE International. “E/E Diagnostic Test Modes.” SAE J1979, 2017.
5. Savarese, M., et al. “P.I.E.N.O.–Petrol-Filling Itinerary Estimation aNd Optimization.” IEEE Access, 2024.
6. Savarese, M., et al. “RI-PIENO – Revised and Improved Petrol-Filling Itinerary Estimation aNd Optimization.” IEEE CCNC, 2026.
7. Taylor, S. J., & Letham, B. “Forecasting at Scale.” *The American Statistician*, 2018.

## Citation
```bibtex
@inproceedings{savarese2025ripieno,
  author       = {Savarese, Marco and De Blasi, Antonio and Zaccagnino, Carmine and Salici, Giacomo and Cascianelli, Silvia and Vezzani, Roberto and Grazia, Carlo Augusto},
  title        = {RI-PIENO: Revised and Improved Petrol-Filling Itinerary Estimation aNd Optimization},
  booktitle    = {IEEE Consumer Communications and Networking Conference (CCNC)},
  year         = {2026},
  address      = {Las Vegas, USA},
  month        = jan,
  note         = {Conference paper},
  url          = {https://www.researchgate.net/publication/396507184_RI-PIENO_-Revised_and_Improved_Petrol-Filling_Itinerary_Estimation_aNd_Optimization}
}

@ARTICLE{savarese2024pieno,
  author={Savarese, Marco and De Blasi, Antonio and Zaccagnino, Carmine and Grazia, Carlo Augusto},
  journal={IEEE Access},
  title={{P. I. E. N. O.}–{P}etrol-Filling {I}tinerary {E}stimation a{N}d {O}ptimization},
  year={2024},
  volume={12},
  number={},
  pages={158094-158102},
  keywords={Fuels;Optimization;Estimation;Bridges;Routing;Standards;Routing protocols;Real-time systems;Mobile applications;Market research;Artificial Intelligence;cloud computing;edge computing;intelligent transportation systems;microcontrollers;mobile communication;mobile applications;smart mobility;smart transportation;time series analysis;vehicle-to-everything},
  doi={10.1109/ACCESS.2024.3483959}
}
```
