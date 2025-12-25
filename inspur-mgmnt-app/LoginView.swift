//
//  LoginView.swift
//  inspur-mgmnt-app
//
//  Created on 2025-12-25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    @State private var serverIP = ""
    @State private var username = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case serverIP, username, password
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Inspur BMS")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Server Management")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Server Configuration")) {
                    TextField("Server IP Address", text: $serverIP)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .serverIP)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .username
                        }
                }
                
                Section(header: Text("Credentials")) {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .username)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .password
                        }
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit {
                            login()
                        }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.callout)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section {
                    Button(action: login) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid || viewModel.isLoading)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Credentials are securely stored in Keychain")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text("Auto-login on next launch")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadStoredCredentials()
        }
    }
    
    private var isFormValid: Bool {
        !serverIP.isEmpty && !username.isEmpty && !password.isEmpty
    }
    
    private func login() {
        // Validate before attempting login
        guard isFormValid else { return }
        
        focusedField = nil
        
        Task {
            await viewModel.login(serverIP: serverIP, username: username, password: password)
        }
    }
    
    private func loadStoredCredentials() {
        let keychain = KeychainManager.shared
        serverIP = keychain.serverIP ?? ""
        username = keychain.username ?? ""
        password = keychain.password ?? ""
    }
}

#Preview {
    LoginView()
        .environmentObject(AppViewModel())
}
