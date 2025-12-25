//
//  KeychainManager.swift
//  inspur-mgmnt-app
//
//  Created on 2025-12-25.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    enum KeychainError: Error {
        case itemNotFound
        case duplicateItem
        case invalidItemFormat
        case unexpectedStatus(OSStatus)
    }
    
    // MARK: - Save
    
    func save(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item if present
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func save(_ string: String, forKey key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        try save(data, forKey: key)
    }
    
    // MARK: - Retrieve
    
    func retrieve(forKey key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw status == errSecItemNotFound ? KeychainError.itemNotFound : KeychainError.unexpectedStatus(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidItemFormat
        }
        
        return data
    }
    
    func retrieveString(forKey key: String) throws -> String {
        let data = try retrieve(forKey: key)
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        
        return string
    }
    
    // MARK: - Delete
    
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    // MARK: - App-Specific Keys
    
    private enum Keys {
        static let serverIP = "com.inspurapp.serverIP"
        static let username = "com.inspurapp.username"
        static let password = "com.inspurapp.password"
        static let sessionID = "com.inspurapp.sessionID"
        static let csrfToken = "com.inspurapp.csrfToken"
    }
    
    // Server IP
    var serverIP: String? {
        get { try? retrieveString(forKey: Keys.serverIP) }
        set {
            if let value = newValue {
                try? save(value, forKey: Keys.serverIP)
            } else {
                try? delete(forKey: Keys.serverIP)
            }
        }
    }
    
    // Username
    var username: String? {
        get { try? retrieveString(forKey: Keys.username) }
        set {
            if let value = newValue {
                try? save(value, forKey: Keys.username)
            } else {
                try? delete(forKey: Keys.username)
            }
        }
    }
    
    // Password
    var password: String? {
        get { try? retrieveString(forKey: Keys.password) }
        set {
            if let value = newValue {
                try? save(value, forKey: Keys.password)
            } else {
                try? delete(forKey: Keys.password)
            }
        }
    }
    
    // Session ID
    var sessionID: String? {
        get { try? retrieveString(forKey: Keys.sessionID) }
        set {
            if let value = newValue {
                try? save(value, forKey: Keys.sessionID)
            } else {
                try? delete(forKey: Keys.sessionID)
            }
        }
    }
    
    // CSRF Token
    var csrfToken: String? {
        get { try? retrieveString(forKey: Keys.csrfToken) }
        set {
            if let value = newValue {
                try? save(value, forKey: Keys.csrfToken)
            } else {
                try? delete(forKey: Keys.csrfToken)
            }
        }
    }
    
    // Clear all credentials
    func clearAll() {
        serverIP = nil
        username = nil
        password = nil
        sessionID = nil
        csrfToken = nil
    }
    
    // Check if credentials exist
    var hasStoredCredentials: Bool {
        return serverIP != nil && username != nil && password != nil
    }
}
