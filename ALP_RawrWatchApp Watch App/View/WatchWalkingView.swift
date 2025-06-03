//
//  WatchWalkingView.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 01/06/25.
//

import SwiftUI

struct WatchWalkingView: View {
    @ObservedObject var connectivity: iOSConnectivity
    @State private var showingWalkingView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Text("Walk Assistant")
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack {
                    Image(systemName: connectivity.isParentVerified ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(connectivity.isParentVerified ? .green : .red)
                    
                    Text(connectivity.isParentVerified ? "Parent Verified" : "Parent Not Verified")
                        .font(.caption2)
                        .foregroundColor(connectivity.isParentVerified ? .green : .red)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(connectivity.isParentVerified ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )

                // Start Walking Button
                Button(action: {
                    connectivity.sendWalkToiOS()
                    showingWalkingView = true
                    print("Walk button pressed - navigating to walking view")
                }) {
                    HStack {
                        Image(systemName: "figure.walk")
                        Text("Start Walking")
                    }
                }
                .disabled(!connectivity.isParentVerified)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                // Current walking status indicator
                if connectivity.isWalking {
                    HStack {
                        Image(systemName: "figure.walk.circle.fill")
                            .foregroundColor(.blue)
                        Text("Walking Active")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
            }
            .padding()
            .navigationDestination(isPresented: $showingWalkingView) {
                ActiveWalkingView(connectivity: connectivity)
            }
        }
    }
}


#Preview {
    WatchWalkingView(connectivity: iOSConnectivity())
}
