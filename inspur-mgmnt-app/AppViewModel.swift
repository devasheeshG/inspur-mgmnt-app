//
//  AppViewModel.swift
//  inspur-mgmnt-app
//
//  Created on 2025-12-25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Server data
    @Published var powerStatus: PowerStatus?
    @Published var fanInfo: FanInfo?
    @Published var psuInfo: PSUInfo?
    @Published var lastUpdated: Date?
    
    // Fetch state
    private var isFetching = false
    
    // Polling timer
    private var pollingTimer: Timer?
    
    private let apiService = APIService.shared
    private let keychain = KeychainManager.shared
    
    init() {
        // Check if we have stored credentials
        if keychain.hasStoredCredentials {
            Task {
                await attemptAutoLogin()
            }
        }
    }
    
    // MARK: - Authentication
    
    func login(serverIP: String, username: String, password: String) async {
        print("[DEBUG] 🔐 Attempting login to server: \(serverIP)")
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiService.login(serverIP: serverIP, username: username, password: password)
            print("[DEBUG] ✓ Login successful")
            isAuthenticated = true
            
            // Start polling for data
            await fetchAllData()
            startPolling()
        } catch {
            print("[DEBUG] ✗ Login failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func attemptAutoLogin() async {
        print("[DEBUG] 🔓 Attempting auto-login with stored credentials")
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiService.loginWithStoredCredentials()
            print("[DEBUG] ✓ Auto-login successful")
            isAuthenticated = true
            
            // Start polling for data
            await fetchAllData()
            startPolling()
        } catch {
            print("[DEBUG] ✗ Auto-login failed: \(error.localizedDescription)")
            // Silent fail for auto-login
            isAuthenticated = false
            keychain.clearAll()
        }
        
        isLoading = false
    }
    
    func logout() {
        print("[DEBUG] 🚪 Logging out and clearing session")
        isAuthenticated = false
        stopPolling()
        keychain.clearAll()
        print("[DEBUG] ✓ Logout complete")
        
        // Clear data
        powerStatus = nil
        fanInfo = nil
        psuInfo = nil
    }
    
    // MARK: - Data Fetching
    
    func fetchAllData() async {
        // Prevent overlapping fetches
        guard !isFetching else {
            print("[DEBUG] Fetch already in progress, skipping")
            return
        }
        
        isFetching = true
        errorMessage = nil  // Clear previous errors
        var fetchErrors = 0
        
        print("[DEBUG] Starting data fetch...")
        
        await withTaskGroup(of: Bool.self) { group in
            group.addTask { await self.fetchPowerStatus() }
            group.addTask { await self.fetchFanInfo() }
            group.addTask { await self.fetchPSUInfo() }
            
            for await success in group {
                if !success {
                    fetchErrors += 1
                }
            }
        }
        
        // Only update timestamp if all fetches succeeded
        if fetchErrors == 0 {
            lastUpdated = Date()
            print("[DEBUG] All fetches succeeded, timestamp updated")
        } else {
            print("[DEBUG] ❌ Fetch failed: \(fetchErrors) error(s). Timestamp NOT updated.")
        }
        
        isFetching = false
    }
    
    func fetchPowerStatus() async -> Bool {
        do {
            powerStatus = try await apiService.getPowerStatus()
            print("[DEBUG] ✓ Power status fetched")
            return true
        } catch {
            print("[DEBUG] ✗ Power status fetch failed: \(error.localizedDescription)")
            handleError(error)
            return false
        }
    }
    
    func fetchFanInfo() async -> Bool {
        do {
            fanInfo = try await apiService.getFanInfo()
            print("[DEBUG] ✓ Fan info fetched")
            return true
        } catch {
            print("[DEBUG] ✗ Fan info fetch failed: \(error.localizedDescription)")
            handleError(error)
            return false
        }
    }
    
    func fetchPSUInfo() async -> Bool {
        do {
            psuInfo = try await apiService.getPSUInfo()
            print("[DEBUG] ✓ PSU info fetched")
            return true
        } catch {
            print("[DEBUG] ✗ PSU info fetch failed: \(error.localizedDescription)")
            handleError(error)
            return false
        }
    }
    
    // MARK: - Power Control
    
    func powerOn() async {
        print("[DEBUG] ⚡️ Sending power on command")
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.powerOn()
            print("[DEBUG] ✓ Power on command sent successfully")
            
            // Wait a moment and refresh status
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            await fetchPowerStatus()
        } catch {
            print("[DEBUG] ✗ Power on failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Fan Control
    
    func setFanSpeed(fanId: Int, duty: Int) async {
        print("[DEBUG] 🌀 Setting fan \(fanId) speed to \(duty)%")
        do {
            try await apiService.setFanSpeed(fanId: fanId, duty: duty)
            print("[DEBUG] ✓ Fan \(fanId) speed set successfully")
            
            // Refresh fan info after a short delay
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await fetchFanInfo()
        } catch {
            print("[DEBUG] ✗ Fan \(fanId) speed change failed: \(error.localizedDescription)")
            handleError(error)
        }
    }
    
    // MARK: - Polling
    
    func startPolling() {
        print("[DEBUG] ⏱️ Starting 5-second polling timer")
        // Poll every 5 seconds
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchAllData()
            }
        }
    }
    
    func stopPolling() {
        print("[DEBUG] ⏹️ Stopping polling timer")
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: Error) {
        // Ignore cancellation errors (expected when refreshing)
        if let urlError = error as? URLError, urlError.code == .cancelled {
            print("[DEBUG] Request cancelled (expected during refresh)")
            return
        }
        
        print("[DEBUG] Error details: \(error)")
        
        if let apiError = error as? APIService.APIError {
            switch apiError {
            case .unauthorized:
                print("[DEBUG] Unauthorized - attempting re-login")
                // Session expired, try to re-login
                Task {
                    await attemptAutoLogin()
                }
            case .networkError(let underlyingError):
                // Check if underlying error is cancellation
                if let urlError = underlyingError as? URLError, urlError.code == .cancelled {
                    print("[DEBUG] Underlying network error is cancellation")
                    return
                }
                print("[DEBUG] Network error: \(underlyingError.localizedDescription)")
                errorMessage = apiError.localizedDescription
            default:
                print("[DEBUG] API error: \(apiError.localizedDescription)")
                errorMessage = apiError.localizedDescription
            }
        } else {
            print("[DEBUG] General error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
}
