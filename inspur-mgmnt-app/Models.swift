//
//  Models.swift
//  inspur-mgmnt-app
//
//  Created on 2025-12-25.
//

import Foundation

// MARK: - Authentication Models

struct LoginResponse: Codable {
    let ok: Int
    let privilege: Int
    let extendedpriv: Int
    let racsessionId: Int
    let remoteAddr: String
    let serverName: String
    let serverAddr: String
    let httpsEnabled: Int
    let csrfToken: String
    
    enum CodingKeys: String, CodingKey {
        case ok
        case privilege
        case extendedpriv
        case racsessionId = "racsession_id"
        case remoteAddr = "remote_addr"
        case serverName = "server_name"
        case serverAddr = "server_addr"
        case httpsEnabled = "HTTPSEnabled"
        case csrfToken = "CSRFToken"
    }
}

// MARK: - Power Models

struct PowerStatus: Codable {
    let powerStatus: Int
    let ledStatus: Int
    
    enum CodingKeys: String, CodingKey {
        case powerStatus = "power_status"
        case ledStatus = "led_status"
    }
    
    var isPowerOn: Bool {
        powerStatus == 1
    }
}

struct PowerCommand: Codable {
    let powerCommand: Int
    
    enum CodingKeys: String, CodingKey {
        case powerCommand = "power_command"
    }
}

// MARK: - Fan Models

struct FanMode: Codable {
    let controlMode: String
    
    enum CodingKeys: String, CodingKey {
        case controlMode = "control_mode"
    }
    
    var isManual: Bool {
        controlMode == "manual"
    }
}

struct Fan: Codable, Identifiable {
    let id: Int
    let index: Int
    let present: Int
    let status: Int
    let speedRpm: Int
    let speedPercent: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case index
        case present
        case status
        case speedRpm = "speed_rpm"
        case speedPercent = "speed_percent"
    }
    
    var isPresent: Bool {
        present == 1
    }
    
    var isNormal: Bool {
        status == 0
    }
}

struct FanInfo: Codable {
    let fans: [Fan]
    let fansPower: Int
    let controlMode: String
    
    enum CodingKeys: String, CodingKey {
        case fans
        case fansPower = "fans_power"
        case controlMode = "control_mode"
    }
}

struct FanDuty: Codable {
    let duty: Int
}

// MARK: - PSU Models

struct PowerSupply: Codable, Identifiable {
    let id: Int
    let present: Int
    let powerStatus: Int
    let vendorId: String
    let model: String
    let serialNum: String
    let partNum: String
    let ratedPower: Int
    let fwVer: String
    let temperature: Int
    let psFanStatus: String
    let psFanSpeed: Int
    let psInPower: Int
    let psOutPower: Int
    let psInVolt: Int
    let psOutVolt: Int
    let psInCurrent: Int
    let psOutCurrent: Int
    let psOutPowerMax: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case present
        case powerStatus = "power_status"
        case vendorId = "vendor_id"
        case model
        case serialNum = "serial_num"
        case partNum = "part_num"
        case ratedPower = "rated_power"
        case fwVer = "fw_ver"
        case temperature
        case psFanStatus = "ps_fan_status"
        case psFanSpeed = "ps_fan_speed"
        case psInPower = "ps_in_power"
        case psOutPower = "ps_out_power"
        case psInVolt = "ps_in_volt"
        case psOutVolt = "ps_out_volt"
        case psInCurrent = "ps_in_current"
        case psOutCurrent = "ps_out_current"
        case psOutPowerMax = "ps_out_power_max"
    }
    
    var isPresent: Bool {
        present == 1
    }
    
    var inputPowerWatts: Int {
        psInPower
    }
    
    var outputPowerWatts: Int {
        psOutPower
    }
    
    var efficiency: Double {
        guard psInPower > 0 else { return 0 }
        return Double(psOutPower) / Double(psInPower) * 100
    }
}

struct PSUInfo: Codable {
    let presentPowerReading: Int
    let ratedPower: Int
    let hemMode: String
    let powerSuppliesRedundant: String
    let powerSupplies: [PowerSupply]
    
    enum CodingKeys: String, CodingKey {
        case presentPowerReading = "present_power_reading"
        case ratedPower = "rated_power"
        case hemMode = "hem_mode"
        case powerSuppliesRedundant = "power_supplies_redundant"
        case powerSupplies = "power_supplies"
    }
    
    var totalInputPower: Int {
        powerSupplies.reduce(0) { $0 + $1.psInPower }
    }
    
    var totalOutputPower: Int {
        powerSupplies.reduce(0) { $0 + $1.psOutPower }
    }
}

// MARK: - Sensor Models

struct Sensor: Codable, Identifiable {
    let id: Int
    let sensorNumber: Int
    let name: String
    let ownerId: Int
    let ownerLun: Int
    let rawReading: Double
    let type: String
    let typeNumber: Int
    let reading: Double
    let sensorState: Int
    let discreteState: Int
    let lowerNonRecoverableThreshold: Double
    let lowerCriticalThreshold: Double
    let lowerNonCriticalThreshold: Double
    let higherNonCriticalThreshold: Double
    let higherCriticalThreshold: Double
    let higherNonRecoverableThreshold: Double
    let accessible: Int
    let unit: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case sensorNumber = "sensor_number"
        case name
        case ownerId = "owner_id"
        case ownerLun = "owner_lun"
        case rawReading = "raw_reading"
        case type
        case typeNumber = "type_number"
        case reading
        case sensorState = "sensor_state"
        case discreteState = "discrete_state"
        case lowerNonRecoverableThreshold = "lower_non_recoverable_threshold"
        case lowerCriticalThreshold = "lower_critical_threshold"
        case lowerNonCriticalThreshold = "lower_non_critical_threshold"
        case higherNonCriticalThreshold = "higher_non_critical_threshold"
        case higherCriticalThreshold = "higher_critical_threshold"
        case higherNonRecoverableThreshold = "higher_non_recoverable_threshold"
        case accessible
        case unit
    }
}

struct CPUTemperature: Identifiable {
    let id: Int // CPU number (0, 1)
    let temperature: Double // Temperature in Celsius
}
