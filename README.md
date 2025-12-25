# Inspur BMS Management App

A native iOS app for managing your Inspur server through its BMC interface.

## Features

1. **Power Control** - Power on your server remotely with status indicator
2. **CPU Temperature Monitoring** - Real-time temperature display for both CPUs with color-coded alerts
3. **Fan Mode Toggle** - Switch between automatic and manual fan control modes
4. **Set All Fans** - Quickly set all fans to the same speed at once (manual mode only)
5. **Fan Speed Control** - Manually adjust all 8 fans independently (0-100%)
6. **PSU Monitoring** - Real-time power consumption and temperature for both PSUs
7. **Secure Credential Storage** - Login once, credentials stored in iOS Keychain
7. **Auto-Login** - Automatically reconnects on app launch with stored credentials
8. **Session Management** - Handles CSRF tokens and session cookies automatically
9. **SSL Support** - Works with self-signed BMC certificates
10. **Auto-Refresh** - 5-second polling for real-time data updates
11. **Last Updated Timestamp** - Shows exact time of last successful data refresh
12. **Debug Logging** - Comprehensive console logs for troubleshooting

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

### CPU Temperature Card
- Real-time temperature for each CPU (CPU0, CPU1)
- Large temperature display with thermometer icon
- Color-coded temperatures:
  - Green: < 40°C (cool)
  - Orange: 40-60°C (warm)
  - Red: > 60°C (hot)
- Auto-updates every 5 seconds

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

## API Documentation

See [INSPUR_API_DOCUMENTATION.md](INSPUR_API_DOCUMENTATION.md) for complete API reference.
