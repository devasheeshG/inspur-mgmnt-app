# App Screenshots & Flow

## Authentication Flow

```
┌─────────────────────────┐
│     Login Screen        │
│                         │
│  ┌─────────────────┐   │
│  │ Server IP       │   │
│  └─────────────────┘   │
│  ┌─────────────────┐   │
│  │ Username        │   │
│  └─────────────────┘   │
│  ┌─────────────────┐   │
│  │ Password        │   │
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │   Sign In       │   │
│  └─────────────────┘   │
│                         │
│  ✓ Stored in Keychain   │
│  ✓ Auto-login enabled   │
└─────────────────────────┘
```

## Main Dashboard

```
┌─────────────────────────────────────┐
│  Server Control      [Menu]         │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⚡ Power Control    ● ON    │   │
│  │                             │   │
│  │  ┌─────────────────────┐   │   │
│  │  │   🔌 Power On       │   │   │
│  │  └─────────────────────┘   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⚡ Power Supply Units       │   │
│  │                             │   │
│  │  Total: 150W In | 170W Out │   │
│  │                             │   │
│  │  PSU 1                      │   │
│  │  ↓ 76W In  ↑ 68W Out 20°C  │   │
│  │  Efficiency: 89.5%          │   │
│  │                             │   │
│  │  PSU 2                      │   │
│  │  ↓ 74W In  ↑ 102W Out 21°C │   │
│  │  Efficiency: 137.8%         │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🌀 Fan Control   ● MANUAL   │   │
│  │                             │   │
│  │  Fan 0     2688 RPM  20%   │   │
│  │  🐢 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ 🐇 20% │   │
│  │                             │   │
│  │  Fan 1     3360 RPM  20%   │   │
│  │  🐢 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ 🐇 20% │   │
│  │                             │   │
│  │  Fan 2     2688 RPM  20%   │   │
│  │  🐢 ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ 🐇 20% │   │
│  │                             │   │
│  │  ... (5 more fans)          │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

## Key Features

### 1. Power Control
- **ON Indicator** - Green dot shows server is powered on
- **Power On Button** - Large, prominent button
- **Disabled State** - Grayed out when server is already on
- **No Power Off** - Safety feature to prevent accidental shutdowns

### 2. PSU Monitoring
- **Real-time Data** - Updates every 5 seconds
- **Dual Display** - Shows both PSUs side-by-side
- **Metrics:**
  - Input Power (Watts)
  - Output Power (Watts)
  - Temperature (°C)
  - Efficiency (%)
  - Model & Serial Number

### 3. Fan Control
- **8 Independent Fans** - Each with its own slider
- **Live RPM** - Current fan speed in RPM
- **Percentage** - Speed as percentage (0-100%)
- **Smooth Updates** - Debounced slider changes
- **Visual Feedback** - Tortoise/hare icons for min/max

### 4. Auto-Refresh
- **5-Second Polling** - Continuous updates when active
- **Pull-to-Refresh** - Manual refresh gesture
- **Smart Updates** - Auto-refresh after changes

## Color Scheme

- **Power:** Green (on) / Red (off)
- **PSU:** Yellow/Orange indicators
- **Fans:** Blue theme
- **Status:** Green (good), Red (error), Orange (warning)

## Navigation

```
Login Screen
     │
     ▼
Dashboard ←─→ Menu (Refresh, Logout)
```

## Security Features

1. **Keychain Storage** - All credentials encrypted
2. **Session Tokens** - CSRF protection
3. **Auto-Logout** - On authentication errors
4. **SSL Support** - Self-signed certificate handling
