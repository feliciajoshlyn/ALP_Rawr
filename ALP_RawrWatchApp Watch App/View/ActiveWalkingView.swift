//
//  ActiveWalkingView.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by Dave Wirjoatmodjo on 02/06/25.
//

import SwiftUI

struct ActiveWalkingView: View {
    @ObservedObject var connectivity: iOSConnectivity
    @Environment(\.dismiss) private var dismiss
    @State private var walkingTime: Int = 0
    @State private var timer: Timer?
    @State private var showingSaveAlert = false
    @State private var walkDistance: Double = 0.0
    @State private var walkDuration: TimeInterval = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🚶 Walking...")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            HStack(spacing: 10) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .scaleEffect(walkingAnimation(for: index))
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: walkingTime
                        )
                }
            }
            
            // Timer display
            Text(formatTime(walkingTime))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Walking stats (if available from iOS)
            if walkDistance > 0 || walkDuration > 0 {
                VStack(spacing: 8) {
                    HStack {
                        Text("Distance:")
                            .font(.caption)
                        Spacer()
                        Text("\(String(format: "%.1f", walkDistance)) m")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Duration:")
                            .font(.caption)
                        Spacer()
                        Text(formatTime(Int(walkDuration)))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            Text("Keep walking with your parent!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Stop walking button
            Button("Stop Walking") {
                stopWalking()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .foregroundColor(.red)
            
            // Back button
            Button("Back to Main") {
                // If still walking, stop first
                if connectivity.isWalking {
                    stopWalking()
                }
                dismiss()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .onAppear {
            startTimer()
            // Start walking on iOS when view appears
            startWalkingOnIOS()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: connectivity.isWalking) { _, isWalking in
            if !isWalking && timer != nil {
                // Walking stopped from iOS side
                stopTimer()
                showWalkCompletedAlert()
            }
        }
        .alert("Walk Completed! 🎉", isPresented: $showingSaveAlert) {
            Button("Great!") {
                dismiss()
            }
        } message: {
            Text("Your walking session has been saved! Great job staying active with your parent.")
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            walkingTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startWalkingOnIOS() {
        // Send message to iOS to start walking
        connectivity.sendWalkToiOS()
    }
    
    private func stopWalking() {
        // Send message to iOS to stop walking
        connectivity.sendStopWalkingToiOS()
        stopTimer()
        showWalkCompletedAlert()
    }
    
    private func showWalkCompletedAlert() {
        // Add a small delay to ensure data is processed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingSaveAlert = true
        }
    }
    
    private func walkingAnimation(for index: Int) -> CGFloat {
        let phase = (walkingTime + index) % 3
        return phase == 0 ? 1.5 : 1.0
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    ActiveWalkingView(connectivity: iOSConnectivity())
}
