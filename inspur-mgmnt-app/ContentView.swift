//
//  ContentView.swift
//  inspur-mgmnt-app
//
//  Created by Devasheesh Mishra on 25/12/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Last Updated Section
                    if let lastUpdated = viewModel.lastUpdated {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.secondary)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last Updated")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(lastUpdated.formatted(date: .omitted, time: .standard))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text(lastUpdated, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    // Power Control Section
                    PowerControlCard(viewModel: viewModel)
                    
                    // PSU Monitoring Section
                    if let psuInfo = viewModel.psuInfo {
                        PSUMonitoringCard(psuInfo: psuInfo)
                    }
                    
                    // Fan Control Section
                    if let fanInfo = viewModel.fanInfo {
                        FanControlCard(fanInfo: fanInfo, viewModel: viewModel)
                    }
                }
                .padding()
            }
            .navigationTitle("Server Control")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive, action: { viewModel.logout() }) {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
    }
}

// MARK: - Power Control Card

struct PowerControlCard: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "power")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("Power Control")
                    .font(.headline)
                Spacer()
                
                if let status = viewModel.powerStatus {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(status.isPowerOn ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(status.isPowerOn ? "ON" : "OFF")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(status.isPowerOn ? .green : .red)
                    }
                }
            }
            
            Button(action: {
                Task {
                    await viewModel.powerOn()
                }
            }) {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "power")
                        Text("Power On Server")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding()
                .background(
                    (viewModel.powerStatus?.isPowerOn ?? false) ? Color.gray : Color.green
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.powerStatus?.isPowerOn ?? false || viewModel.isLoading)
            
            if let errorMessage = viewModel.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - PSU Monitoring Card

struct PSUMonitoringCard: View {
    let psuInfo: PSUInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                Text("Power Supply Units")
                    .font(.headline)
                Spacer()
            }
            
            // Total Power
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Input Power")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(psuInfo.totalInputPower) W")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Output Power")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(psuInfo.totalOutputPower) W")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Individual PSUs
            ForEach(psuInfo.powerSupplies.filter { $0.isPresent }) { psu in
                PSUDetailView(psu: psu)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct PSUDetailView: View {
    let psu: PowerSupply
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PSU \(psu.id)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(psu.model)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        Text("\(psu.inputPowerWatts) W")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                        Text("\(psu.outputPowerWatts) W")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "thermometer")
                            .font(.title3)
                            .foregroundColor(.orange)
                        Text("\(psu.temperature)°C")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "gauge.high")
                            .font(.title3)
                            .foregroundColor(.green)
                        Text(String(format: "%.1f%%", psu.efficiency))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Fan Control Card

struct FanControlCard: View {
    let fanInfo: FanInfo
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fan.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Fan Control")
                    .font(.headline)
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(fanInfo.controlMode == "manual" ? Color.blue : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(fanInfo.controlMode.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(fanInfo.controlMode == "manual" ? .blue : .orange)
                }
            }
            
            ForEach(fanInfo.fans.filter { $0.isPresent }) { fan in
                FanSliderView(fan: fan, viewModel: viewModel)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct FanSliderView: View {
    let fan: Fan
    @ObservedObject var viewModel: AppViewModel
    @State private var sliderValue: Double
    @State private var isChanging = false
    
    init(fan: Fan, viewModel: AppViewModel) {
        self.fan = fan
        self.viewModel = viewModel
        _sliderValue = State(initialValue: Double(fan.speedPercent))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Fan \(fan.id)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(fan.speedRpm) RPM")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(fan.speedPercent)%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "tortoise.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Slider(value: $sliderValue, in: 0...100, step: 5) { editing in
                    isChanging = editing
                    if !editing {
                        // User finished dragging
                        Task {
                            await viewModel.setFanSpeed(fanId: fan.id, duty: Int(sliderValue))
                        }
                    }
                }
                .tint(.blue)
                
                Image(systemName: "hare.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("\(Int(sliderValue))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
        .onChange(of: fan.speedPercent) { newValue in
            if !isChanging {
                sliderValue = Double(newValue)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
