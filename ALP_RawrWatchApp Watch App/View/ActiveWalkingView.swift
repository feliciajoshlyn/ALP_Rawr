//
//  ActiveWalkingView.swift
//  ALP_RawrWatchApp Watch App
//
//  Updated to use iOS LocationViewModel timer synchronization
//

import SwiftUI

struct ActiveWalkingView: View {
    @ObservedObject var connectivity: iOSConnectivity
    @Environment(\.dismiss) private var dismiss
    @State private var showingSaveAlert = false
    @State private var animationTimer: Timer?
    @State private var animationCounter: Int = 0
    
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
                            value: animationCounter
                        )
                }
            }
            
            // Timer display using synchronized iOS data
            Text(formatTime(Int(connectivity.walkingDuration)))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Walking stats synchronized from iOS LocationViewModel
            VStack(spacing: 8) {
                HStack {
                    Text("Distance:")
                        .font(.caption)
                    Spacer()
                    Text("\(String(format: "%.1f", connectivity.walkingDistance)) m")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Duration:")
                        .font(.caption)
                    Spacer()
                    Text(formatTime(Int(connectivity.walkingDuration)))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            Text("Keep walking with your parent!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Stop walking button
            Button("Stop Walking") {
                connectivity.sendStopWalkingToiOS()
                stopAnimationTimer()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingSaveAlert = true
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .foregroundColor(.red)
            
            // Back button
            Button("Back to Main") {
                if connectivity.isWalking {
                    connectivity.sendStopWalkingToiOS()
                }
                dismiss()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .onAppear {
            startAnimationTimer()
            connectivity.sendWalkToiOS()
        }
        .onDisappear {
            stopAnimationTimer()
        }
        .onChange(of: connectivity.isWalking) { _, isWalking in
            if !isWalking && animationTimer != nil {
                stopAnimationTimer()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingSaveAlert = true
                }
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
    
    // cuma buat animasi start timer
    private func startAnimationTimer() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            animationCounter += 1
        }
    }
    
    // animasinya dimatiin
    private func stopAnimationTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func walkingAnimation(for index: Int) -> CGFloat {
        let phase = (animationCounter + index) % 3
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
