# Inspur BMS Management App

A native iOS app for managing your Inspur server through its BMC interface.

## Features

1. **Power Control** - Power on your server remotely with status indicator
2. **Fan Mode Toggle** - Switch between automatic and manual fan control modes
3. **Set All Fans** - Quickly set all fans to the same speed at once (manual mode only)
4. **Fan Speed Control** - Manually adjust all 8 fans independently (0-100%)
5. **PSU Monitoring** - Real-time power consumption and temperature for both PSUs
6. **Secure Credential Storage** - Login once, credentials stored in iOS Keychain
7. **Auto-Login** - Automatically reconnects on app launch with stored credentials
8. **Session Management** - Handles CSRF tokens and session cookies automatically
9. **SSL Support** - Works with self-signed BMC certificates
10. **Auto-Refresh** - 5-second polling for real-time data updates
11. **Last Updated Timestamp** - Shows exact time of last successful data refresh
12. **Debug Logging** - Comprehensive console logs for troubleshooting

## Architecture

### Files Created
- **Models.swift** - Data models for API responses (LoginResponse, PowerStatus, FanInfo, PSUInfo)
- **KeychainManager.swift** - Secure credential storage using iOS Keychain
- **APIService.swift** - Network layer with URLSession, authentication, and all API endpoints
- **AppViewModel.swift** - Main view model with ObservableObject for state management
- **LoginView.swift** - Login screen with server IP, username, and password fields
- **ContentView.swift** - Main dashboard with power control, fan sliders, and PSU cards
- **inspur_mgmnt_appApp.swift** - App entry point with authentication flow

### API Endpoints Used
- `POST /api/session` - Authentication with username/password
- `GET /api/chassis-status` - Get current power status (on/off)
- `POST /api/actions/power` - Send power on command
- `GET /api/settings/fans-mode` - Get current fan control mode
- `PUT /api/settings/fans-mode` - Set fan control mode (auto/manual)
- `GET /api/status/fan_info` - Get all fan speeds, RPMs, and status
- `PUT /api/settings/fan/{id}` - Set individual fan speed (manual mode only)
- `GET /api/status/psu_info` - Get PSU power consumption, temperature, and efficiency

## Usage

1. **First Launch:**
   - Enter your BMC IP address (e.g., 192.168.0.200)
   - Enter BMC username
   - Enter BMC password
   - Tap "Sign In"

2. **Dashboard:**
   - **Last Updated Timestamp** - Shows exact date and time of last data refresh
   - **Power On Button** - Tap to power on the server (disabled when already on)
   - **PSU Cards** - View total and individual PSU metrics:
     - Input power (from wall outlet)
     - Output power (to server components)
     - Temperature (°C)
   - **Fan Mode Toggle** - Switch between Auto and Manual control
   - **Set All Fans** - Quick slider to set all fans to same speed (manual mode only)
   - **Fan Sliders** - Drag to adjust individual fan speeds (0-100%) when in Manual mode
   - **Auto-Refresh** - Data updates automatically every 5 seconds
   - **Logout** - Toolbar button to clear credentials and return to login

3. **Auto-Login:**
   - On subsequent launches, app automatically logs in with saved credentials
   - If session expires, app automatically re-authenticates

## Configuration

### Server Requirements
- Inspur server with BMC web interface
- HTTPS enabled on BMC
- Network connectivity from iOS device to BMC

### App Settings
- **Polling Interval:** 5 seconds (configured in AppViewModel)
- **Request Timeout:** 30 seconds
- **SSL Validation:** Disabled for self-signed certificates

## Security Notes

⚠️ **Important:**
- Credentials stored securely in iOS Keychain
- SSL certificate validation disabled for self-signed BMC certs
- Only power-on functionality exposed (power-off disabled for safety)
- Session tokens automatically managed

## Data Refreshing

- **Automatic:** Every 5 seconds while dashboard is active
- **On Actions:** Automatically refreshes after power/fan/mode changes
- **Timestamp:** Last Updated card shows when data was successfully fetched
- **Error Handling:** Failed fetches don't update timestamp, previous data remains visible

## UI Components

### Last Updated Card
- Clock icon with timestamp
- Shows date and time of last successful data fetch
- Only updates when all data endpoints succeed

### Power Control Card
- Current power status (ON/OFF with colored indicator)
- Power on button (disabled when server is already on)
- Loading spinner during power operations
- Error message display for failed operations

### PSU Monitoring Cards
- Total system input/output power summary
- Individual PSU cards with responsive grid layout:
  - ↓ Input power symbol (blue)
  - ↑ Output power symbol (green)
  - 🌡️ Temperature symbol (orange)
  - Model number display
- Symbol-only design for compact display

### Fan Control Card
- Auto/Manual mode toggle switch
- Mode indicator (orange for Auto, blue for Manual)
- **Set All Fans slider** (purple, manual mode only):
  - Quickly set all 8 fans to the same speed
  - Concurrent API calls for fast updates
  - Loading spinner during operation
- 8 individual fan sliders (only active in Manual mode)
- Current RPM and percentage display for each fan
- Small/large fan icons for speed indication
- Real-time updates every 5 seconds

## Build Information

- **Platform:** iOS 18.6+
- **Language:** Swift 5
- **Framework:** SwiftUI with Grid layouts
- **Architecture:** MVVM pattern
- **Deployment Target:** iOS 18.6+ (Simulator & Device)
- **UI Components:** Native SwiftUI (Grid, Toggle, Slider, Cards)
- **Networking:** URLSession with async/await
- **Storage:** iOS Keychain Services

## API Documentation

See [INSPUR_API_DOCUMENTATION.md](INSPUR_API_DOCUMENTATION.md) for complete API reference.

## Future Enhancements

Potential features to add:
- Temperature monitoring
- Event log viewer
- Network configuration
- User management
- Proxmox hypervisor integration (for safe power-off)
- Widgets for quick status
- Push notifications for alerts
