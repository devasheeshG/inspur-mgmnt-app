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
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiService.login(serverIP: serverIP, username: username, password: password)
            isAuthenticated = true
            
            // Start polling for data
            await fetchAllData()
            startPolling()
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func attemptAutoLogin() async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiService.loginWithStoredCredentials()
            isAuthenticated = true
            
            // Start polling for data
            await fetchAllData()
            startPolling()
        } catch {
            // Silent fail for auto-login
            isAuthenticated = false
            keychain.clearAll()
        }
        
        isLoading = false
    }
    
    func logout() {
        isAuthenticated = false
        stopPolling()
        keychain.clearAll()
        
        // Clear data
        powerStatus = nil
        fanInfo = nil
        psuInfo = nil
    }
    
    // MARK: - Data Fetching
    
    func fetchAllData() async {
        var fetchErrors = 0
        
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
        }
    }
    
    func fetchPowerStatus() async -> Bool {
        do {
            powerStatus = try await apiService.getPowerStatus()
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    func fetchFanInfo() async -> Bool {
        do {
            fanInfo = try await apiService.getFanInfo()
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    func fetchPSUInfo() async -> Bool {
        do {
            psuInfo = try await apiService.getPSUInfo()
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - Power Control
    
    func powerOn() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.powerOn()
            
            // Wait a moment and refresh status
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            await fetchPowerStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Fan Control
    
    func setFanSpeed(fanId: Int, duty: Int) async {
        do {
            try await apiService.setFanSpeed(fanId: fanId, duty: duty)
            
            // Refresh fan info after a short delay
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await fetchFanInfo()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Polling
    
    func startPolling() {
        // Poll every 5 seconds
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchAllData()
            }
        }
    }
    
    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: Error) {
        if let apiError = error as? APIService.APIError {
            switch apiError {
            case .unauthorized:
                // Session expired, try to re-login
                Task {
                    await attemptAutoLogin()
                }
            default:
                errorMessage = apiError.localizedDescription
            }
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
