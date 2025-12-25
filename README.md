# Inspur BMS Management App

A native iOS app for managing your Inspur server through its BMC interface.

## Features

1. **Power Control** - Power on your server remotely (power off disabled for safety)
2. **Fan Speed Control** - Manually adjust all 8 fans independently (0-100%)
3. **PSU Monitoring** - Real-time power consumption for both power supplies
4. **Secure Credential Storage** - Login once, credentials stored in iOS Keychain
5. **Auto-Login** - Automatically reconnects on app launch
6. **Session Management** - Handles CSRF tokens and session cookies
7. **SSL Support** - Works with self-signed BMC certificates

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
- `POST /api/session` - Authentication
- `GET /api/chassis-status` - Power status
- `POST /api/actions/power` - Power control
- `GET /api/status/fan_info` - Fan information
- `PUT /api/settings/fan/{id}` - Set fan speed
- `GET /api/status/psu_info` - Power supply data

## Usage

1. **First Launch:**
   - Enter your BMC IP address (e.g., 192.168.0.200)
   - Enter BMC username
   - Enter BMC password
   - Tap "Sign In"

2. **Dashboard:**
   - **Power On Button** - Tap to power on the server (grayed out when server is on)
   - **PSU Cards** - View input/output power, temperature, and efficiency for each PSU
   - **Fan Sliders** - Drag to adjust fan speed (0-100%), updates in real-time
   - **Refresh** - Pull down to refresh or use menu → Refresh
   - **Logout** - Menu → Logout to clear credentials

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
- **Manual:** Pull-to-refresh gesture or toolbar menu
- **On Actions:** Automatically refreshes after power/fan changes

## UI Components

### Power Control Card
- Current power status (ON/OFF indicator)
- Green power button (disabled when server is on)
- Error message display

### PSU Monitoring Cards
- Total input/output power
- Individual PSU details:
  - Input power (Watts)
  - Output power (Watts)
  - Temperature (°C)
  - Efficiency percentage
  - Model information

### Fan Control Card
- Control mode indicator (MANUAL/AUTO)
- 8 individual fan sliders
- Current RPM display
- Percentage display
- Real-time updates

## Build Information

- **Platform:** iOS 18.6.2+
- **Language:** Swift 5
- **Framework:** SwiftUI
- **Architecture:** MVVM
- **Deployment Target:** iOS Simulator / Device

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
