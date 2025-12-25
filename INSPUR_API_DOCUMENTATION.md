# Inspur BMS API Documentation

Complete API reference for power control, fan management, and PSU monitoring.

---

## **Base Configuration**

- **Base URL:** `https://192.168.0.200` (your BMC IP address)
- **Protocol:** HTTPS
- **Server:** lighttpd/1.4.35
- **Authentication:** Cookie-based sessions with CSRF protection

---

## **1. Authentication**

### **Login (Create Session)**

**Endpoint:** `POST /api/session`

**Request Headers:**
```
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
X-Requested-With: XMLHttpRequest
```

**Request Body:**
```
username=<your-username>&password=<your-password>
```

**Response Headers:**
```
Set-Cookie: QSESSIONID=5f370d268c05dfeb62CcPeziiYwVBx; path=/
Content-Type: application/json
Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
```

**Response Body:**
```json
{
  "ok": 0,
  "privilege": 4,
  "extendedpriv": 259,
  "racsession_id": 2,
  "remote_addr": "192.168.0.23",
  "server_name": "192.168.0.200",
  "server_addr": "192.168.0.200",
  "HTTPSEnabled": 1,
  "CSRFToken": "KZ3raSXV"
}
```

**Important Fields:**
- `CSRFToken`: Required for all subsequent authenticated requests (send as `X-CSRFTOKEN` header)
- `QSESSIONID`: Session cookie (automatically handled by HTTP client)

---

## **2. Power Control**

### **Power On/Off**

**Endpoint:** `POST /api/actions/power`

**Required Headers:**
```
Content-Type: application/json;charset=UTF-8
X-CSRFTOKEN: <token-from-login>
X-Requested-With: XMLHttpRequest
Cookie: QSESSIONID=<session-id>
```

**Request Body:**
```json
{
  "power_command": 1
}
```

**Power Command Values:**
- `1` = Power On
- `0` = Power Off (not recommended per your requirements)

**Response:**
```json
{
  "power_command": 1
}
```

---

### **Get Power Status**

**Endpoint:** `GET /api/chassis-status`

**Required Headers:**
```
X-CSRFTOKEN: <token-from-login>
X-Requested-With: XMLHttpRequest
Cookie: QSESSIONID=<session-id>
```

**Response:**
```json
{
  "power_status": 1,
  "led_status": 0
}
```

**Status Values:**
- `power_status`: `1` = On, `0` = Off
- `led_status`: `1` = LED on, `0` = LED off

---

## **3. Fan Control**

### **Get Fan Mode**

**Endpoint:** `GET /api/settings/fans-mode`

**Required Headers:**
```
X-CSRFTOKEN: <token-from-login>
X-Requested-With: XMLHttpRequest
Cookie: QSESSIONID=<session-id>
```

**Response:**
```json
{
  "control_mode": "manual"
}
```

**Control Mode Values:**
- `"manual"` = Manual fan control enabled
- `"auto"` = Automatic fan control

---

### **Set Fan Mode**

**Endpoint:** `PUT /api/settings/fans-mode`

**Required Headers:**
```
Content-Type: application/json;charset=UTF-8
X-CSRFTOKEN: <token-from-login>
X-Requested-With: XMLHttpRequest
Cookie: QSESSIONID=<session-id>
```

**Request Body:**
```json
{
  "control_mode": "manual"
}
```

**Control Mode Values:**
- `"manual"` = Switch to manual fan control
- `"auto"` = Switch to automatic fan control

**Response:**
```json
{
  "control_mode": "manual"
}
```

**Note:** When switching to automatic mode, the BMC will take over fan speed control based on temperature sensors. When in manual mode, fan speeds can be set individually using the Set Fan Speed endpoint.

---

### **Set Fan Speed**

**Endpoint:** `PUT /api/settings/fan/{fan_id}`

**Fan IDs:** `0` through `7` (8 fans total)

**Required Headers:**
```
Content-Type: application/json;charset=UTF-8
X-CSRFTOKEN: <token-from-login>
X-Requested-With: XMLHttpRequest
Cookie: QSESSIONID=<session-id>
```

**Request Body:**
```json
{
  "duty": 20
}
```

**Duty Cycle:** Integer from `0` to `100` (percentage)

**Response:**
```json
{
  "duty": 20
}
```

**Example URLs:**
- `/api/settings/fan/0` - Fan 0
- `/api/settings/fan/1` - Fan 1
- `/api/settings/fan/7` - Fan 7

---

### **Get Fan Information**

**Endpoint:** `GET /api/status/fan_info`

**Required Headers:**
```
X-CSRFTOKEN: <token-from-login>
X-Requested-With: XMLHttpRequest
Cookie: QSESSIONID=<session-id>
```

**Response:**
```json
{
  "fans": [
    {
      "id": 0,
      "index": 0,
      "present": 1,
      "status": 0,
      "speed_rpm": 2688,
      "speed_percent": 20
    },
    {
      "id": 1,
      "index": 1,
      "present": 1,
      "status": 0,
      "speed_rpm": 3360,
      "speed_percent": 20
    },
    {
      "id": 2,
      "index": 2,
      "present": 1,
      "status": 0,
      "speed_rpm": 2688,
      "speed_percent": 20
    },
    {
      "id": 3,
      "index": 3,
      "present": 1,
      "status": 0,
      "speed_rpm": 3456,
      "speed_percent": 20
    },
    {
      "id": 4,
      "index": 4,
      "present": 1,
      "status": 0,
      "speed_rpm": 2688,
      "speed_percent": 20
    },
    {
      "id": 5,
      "index": 5,
      "present": 1,
      "status": 0,
      "speed_rpm": 3360,
      "speed_percent": 20
    },
    {
      "id": 6,
      "index": 6,
      "present": 1,
      "status": 0,
      "speed_rpm": 2784,
      "speed_percent": 20
    },
    {
      "id": 7,
      "index": 7,
      "present": 1,
      "status": 0,
      "speed_rpm": 3360,
      "speed_percent": 20
    }
  ],
  "fans_power": 0,
  "control_mode": "manual"
}
```

**Fan Object Fields:**
- `id`: Fan identifier (0-7)
- `present`: `1` = fan installed, `0` = not present
- `status`: `0` = normal, other values indicate errors
- `speed_rpm`: Current RPM
- `speed_percent`: Current speed as percentage (0-100)

---

## **4. Power Supply Monitoring**

### **Get PSU Information**

**Endpoint:** `GET /api/status/psu_info`

**Required Headers:**
```
X-CSRFTOKEN: <token-from-login>
X-Requested-With: XMLHttpRequest
Cookie: QSESSIONID=<session-id>
```

**Response:**
```json
{
  "present_power_reading": 0,
  "rated_power": 0,
  "hem_mode": "",
  "power_supplies_redundant": "NOT_REDUNDANT",
  "power_supplies": [
    {
      "id": 1,
      "present": 1,
      "power_status": 0,
      "vendor_id": "LITEON",
      "model": "PS-2801-12L",
      "serial_num": "6K12L012015GTJ",
      "part_num": "",
      "rated_power": 0,
      "fw_ver": "\u0006\b\u0001\u0001",
      "temperature": 20,
      "ps_fan_status": "",
      "ps_fan_speed": 0,
      "ps_in_power": 76,
      "ps_out_power": 68,
      "ps_in_volt": 259,
      "ps_out_volt": 1232,
      "ps_in_current": 41,
      "ps_out_current": 748,
      "ps_out_power_max": 800
    },
    {
      "id": 2,
      "present": 1,
      "power_status": 0,
      "vendor_id": "LITEON",
      "model": "PS-2801-12L",
      "serial_num": "6K12L012015C5W",
      "part_num": "",
      "rated_power": 0,
      "fw_ver": "\u0006\b\u0001\u0001",
      "temperature": 21,
      "ps_fan_status": "",
      "ps_fan_speed": 0,
      "ps_in_power": 74,
      "ps_out_power": 102,
      "ps_in_volt": 256,
      "ps_out_volt": 1222,
      "ps_in_current": 62,
      "ps_out_current": 1153,
      "ps_out_power_max": 800
    }
  ],
  "storage_batteries": [
    {
      "id": 1,
      "present": 0,
      "condition": "",
      "model": "",
      "serial_num": "",
      "max_cap_watts": 0,
      "fw_ver": ""
    }
  ]
}
```

**Key Power Supply Fields:**
- `id`: PSU identifier (1, 2)
- `present`: `1` = PSU installed, `0` = not present
- `ps_in_power`: **Input power in Watts** ← Primary metric for power consumption
- `ps_out_power`: **Output power in Watts** ← Power delivered to system
- `temperature`: PSU temperature in °C
- `ps_in_volt`: Input voltage (AC, typically 230-260V)
- `ps_out_volt`: Output voltage in centivolts (e.g., 1232 = 12.32V DC)
- `ps_in_current`: Input current in centiamps (e.g., 41 = 0.41A)
- `ps_out_current`: Output current in centiamps (e.g., 748 = 7.48A)
- `ps_out_power_max`: Maximum rated output (800W per PSU)

---

## **5. Sensor Monitoring**

### **Get All Sensors**

**Endpoint:** `GET /api/sensors`

**Required Headers:**
```
X-CSRFTOKEN: <token-from-login>
X-Requested-With: XMLHttpRequest
Cookie: QSESSIONID=<session-id>
```

**Response:** Array of sensor objects

**CPU Temperature Sensor Example:**
```json
{
  "id": 3,
  "sensor_number": 6,
  "name": "CPU0_Temp",
  "owner_id": 32,
  "owner_lun": 0,
  "raw_reading": 27.0,
  "type": "temperature",
  "type_number": 1,
  "reading": 27.0,
  "sensor_state": 1,
  "discrete_state": 0,
  "lower_non_recoverable_threshold": 0.0,
  "lower_critical_threshold": 0.0,
  "lower_non_critical_threshold": 0.0,
  "higher_non_critical_threshold": 0.0,
  "higher_critical_threshold": 0.0,
  "higher_non_recoverable_threshold": 0.0,
  "accessible": 0,
  "unit": "deg_c"
}
```

**Key Sensor Fields:**
- `name`: Sensor identifier (e.g., "CPU0_Temp", "CPU1_Temp", "Inlet_Temp")
- `reading`: Current sensor value (temperature in °C for temp sensors)
- `type`: Sensor type ("temperature", "voltage", "fan", etc.)
- `unit`: Unit of measurement ("deg_c" for Celsius)
- `sensor_state`: `1` = active/normal
- Threshold fields define warning/critical limits

**Common Temperature Sensors:**
- `CPU0_Temp` - CPU 0 package temperature
- `CPU1_Temp` - CPU 1 package temperature  
- `Inlet_Temp` - Server inlet air temperature
- `Outlet_Temp` - Server exhaust air temperature
- `CPU0_Margin_Temp` - CPU 0 thermal margin (headroom before throttling)
- `CPU1_Margin_Temp` - CPU 1 thermal margin

**Note:** The `/api/sensors` endpoint returns all system sensors including temperatures, voltages, fan speeds, and power metrics. Filter by `name` field to extract specific sensors of interest.

---

## **Authentication Flow Summary**

1. **Login:** `POST /api/session` with credentials
2. **Extract:** Save `CSRFToken` and `QSESSIONID` cookie from response
3. **All subsequent requests** must include:
   - Header: `X-CSRFTOKEN: <token>`
   - Header: `Cookie: QSESSIONID=<session-id>`
   - Header: `X-Requested-With: XMLHttpRequest`

---

## **Error Handling Notes**

- Session expires after inactivity - re-authenticate if you receive 401/403 responses
- Self-signed SSL certificate - your app must handle certificate validation
- All responses include `Cache-Control: no-store, no-cache` to prevent caching
