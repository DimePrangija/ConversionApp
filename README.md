# ConversionApp

A production-ready SwiftUI iOS 17+ app for converting weight between pounds (lb) and kilograms (kg) with offline-first history, SwiftData persistence, and an optional FastAPI + SQLite backend for syncing conversion logs.

## Project Structure
```
ConversionApp/
  ConversionAppApp.swift          # App entry point and environment injection
  Models/                         # SwiftData models and domain enums
  Services/                       # Conversion logic, haptics, API client, persistence helpers
  ViewModels/                     # MVVM presentation logic
  Views/                          # SwiftUI screens and components
server/                           # FastAPI server with SQLite storage
  main.py                         # API implementation
  requirements.txt                # Server dependencies
  test_server.py                  # Lightweight API tests
tests/                            # iOS unit tests for conversion logic
```

## iOS App
- **Platform:** iOS 17+, SwiftUI, MVVM.
- **Persistence:** SwiftData stores conversion history locally with offline-first behavior.
- **Features:**
  - Live conversion with debouncing and rounding (0–4 decimals) per user preference.
  - Swap units, copy result, and save conversions to history.
  - History list with search, direction filter, swipe-to-delete, and clear-all with confirmation.
  - Settings for default direction, decimal places, and haptics toggle.
  - Accessibility-ready with VoiceOver labels and Dynamic Type-friendly layout.
- **Offline:** All conversions and history work fully offline. If the optional server is unreachable, conversion logs remain locally and are synced when connectivity returns.

### Running the App
1. Open `ConversionApp.xcodeproj` (create an empty project and drop the provided `ConversionApp` folder into it, or initialize a new SwiftUI App target that points to this source set).
2. Set the deployment target to **iOS 17.0** or later and ensure SwiftData is enabled.
3. Run on an iPhone simulator or device. The app operates offline by default; the server URL defaults to `http://localhost:8000` for sync.

### Offline and Sync Behavior
- Saving a conversion writes to SwiftData immediately.
- The app tries to send the conversion to the server; on failure, the record stays marked as unsynced and will retry on next sync trigger (app open or history refresh).
- History and conversions are always available locally regardless of server state.

### Unit Tests (iOS)
Add the `tests/ConversionServiceTests.swift` file to your Xcode test target and run:
```
Product > Test (⌘U)
```
The tests cover conversion correctness and rounding.

## Backend Server (FastAPI + SQLite)
The server is optional; the app works without it. It provides logging and retrieval of conversions for sync.

### Setup
```
cd server
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Run
```
uvicorn main:app --host 0.0.0.0 --port 8000
```
SQLite data persists to `server/db.sqlite3`.

### API
- `POST /convert` — body: `{ id, inputValue, fromUnit, toUnit, result, timestamp }` (logs a conversion)
- `GET /history` — returns last 50 conversions (newest first)
- `DELETE /history` — clears all history
- `GET /health` — simple health check

### API Examples (curl)
```
# Log a conversion
curl -X POST http://localhost:8000/convert \
  -H "Content-Type: application/json" \
  -d '{"id":"test-id","inputValue":10,"fromUnit":"pounds","toUnit":"kilograms","result":4.5359237,"timestamp":"2024-01-01T00:00:00Z"}'

# Fetch history
curl http://localhost:8000/history

# Clear history
curl -X DELETE http://localhost:8000/history
```

### Server Tests
```
cd server
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python -m pytest test_server.py
```

## Offline Testing Tips
- Kill or stop the server, save conversions in the app, then restart the server and revisit the History tab; pending records will sync automatically.
- Toggle Airplane Mode on device/simulator to validate offline conversion and saving.

## Notes for App Store Readiness
- No third-party dependencies on iOS; only system frameworks (SwiftUI, SwiftData, Foundation, UIKit for haptics).
- Clean MVVM separation: Models in `Models/`, view models in `ViewModels/`, services in `Services/`, and UI in `Views/`.
- English localization with extensible string usage; add `.localized()` wrappers as needed for additional locales.
