//
//  APIService.swift
//  inspur-mgmnt-app
//
//  Created on 2025-12-25.
//

import Foundation

class APIService: NSObject {
    static let shared = APIService()
    
    private var session: URLSession!
    private let keychain = KeychainManager.shared
    
    enum APIError: Error, LocalizedError {
        case invalidURL
        case noSessionData
        case invalidResponse
        case decodingError(Error)
        case networkError(Error)
        case httpError(Int)
        case unauthorized
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid server URL"
            case .noSessionData:
                return "No active session. Please log in."
            case .invalidResponse:
                return "Invalid response from server"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .httpError(let code):
                return "HTTP error: \(code)"
            case .unauthorized:
                return "Session expired. Please log in again."
            }
        }
    }
    
    private override init() {
        super.init()
        
        // Configure URLSession with custom delegate for SSL handling
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - Request Builder
    
    private func buildRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = true
    ) throws -> URLRequest {
        guard let url = URL(string: "https://\(keychain.serverIP!)" + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        
        if requiresAuth {
            guard let csrfToken = keychain.csrfToken else {
                throw APIError.noSessionData
            }
            request.setValue(csrfToken, forHTTPHeaderField: "X-CSRFTOKEN")
        }
        
        if let body = body {
            if method == "POST" && endpoint.contains("/session") {
                request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            } else {
                request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            }
            request.httpBody = body
        }
        
        return request
    }
    
    // MARK: - Generic Request Handler
    
    private func performRequest<T: Decodable>(
        _ request: URLRequest
    ) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Extract session cookie if present
            if let headerFields = httpResponse.allHeaderFields as? [String: String],
               let url = response.url {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
                for cookie in cookies {
                    if cookie.name == "QSESSIONID" {
                        keychain.sessionID = cookie.value
                    }
                }
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    throw APIError.unauthorized
                }
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Authentication
    
    func login(serverIP: String, username: String, password: String) async throws -> LoginResponse {
        // Save server IP temporarily for this request
        let previousIP = keychain.serverIP
        keychain.serverIP = serverIP
        
        do {
            let bodyString = "username=\(username)&password=\(password)"
            let bodyData = bodyString.data(using: .utf8)
            
            let request = try buildRequest(
                endpoint: "/api/session",
                method: "POST",
                body: bodyData,
                requiresAuth: false
            )
            
            let response: LoginResponse = try await performRequest(request)
            
            // Save credentials and session data
            keychain.serverIP = serverIP
            keychain.username = username
            keychain.password = password
            keychain.csrfToken = response.csrfToken
            
            return response
        } catch {
            // Restore previous IP if login failed
            keychain.serverIP = previousIP
            throw error
        }
    }
    
    func loginWithStoredCredentials() async throws -> LoginResponse {
        guard let serverIP = keychain.serverIP,
              let username = keychain.username,
              let password = keychain.password else {
            throw APIError.noSessionData
        }
        
        return try await login(serverIP: serverIP, username: username, password: password)
    }
    
    // MARK: - Power Control
    
    func getPowerStatus() async throws -> PowerStatus {
        let request = try buildRequest(endpoint: "/api/chassis-status")
        return try await performRequest(request)
    }
    
    func powerOn() async throws {
        let command = PowerCommand(powerCommand: 1)
        let bodyData = try JSONEncoder().encode(command)
        
        let request = try buildRequest(
            endpoint: "/api/actions/power",
            method: "POST",
            body: bodyData
        )
        
        let _: PowerCommand = try await performRequest(request)
    }
    
    // MARK: - Fan Control
    
    func getFanMode() async throws -> FanMode {
        let request = try buildRequest(endpoint: "/api/settings/fans-mode")
        return try await performRequest(request)
    }
    
    func getFanInfo() async throws -> FanInfo {
        let request = try buildRequest(endpoint: "/api/status/fan_info")
        return try await performRequest(request)
    }
    
    func setFanSpeed(fanId: Int, duty: Int) async throws {
        let fanDuty = FanDuty(duty: duty)
        let bodyData = try JSONEncoder().encode(fanDuty)
        
        let request = try buildRequest(
            endpoint: "/api/settings/fan/\(fanId)",
            method: "PUT",
            body: bodyData
        )
        
        let _: FanDuty = try await performRequest(request)
    }
    
    // MARK: - PSU Monitoring
    
    func getPSUInfo() async throws -> PSUInfo {
        let request = try buildRequest(endpoint: "/api/status/psu_info")
        return try await performRequest(request)
    }
}

// MARK: - URLSessionDelegate for SSL Certificate Handling

extension APIService: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Accept self-signed certificates (for BMC)
        // WARNING: This is insecure for production apps, but necessary for self-signed BMC certs
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
