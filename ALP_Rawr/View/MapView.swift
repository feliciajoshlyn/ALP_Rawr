//
//  MapView.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 23/05/25.
//

import SwiftUI
import MapKit
import CoreLocation
import FirebaseAuth

struct MapView: View {
    @EnvironmentObject var viewModel: LocationViewModel
    @EnvironmentObject var walkViewModel: WalkingViewModel
    @EnvironmentObject var agePredictionViewModel: AgePredictionViewModel
    
    @State private var userLocationWrapper: LocationModel? = nil
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -7.28352, longitude: 112.63169),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    @State private var currentRegion: MKCoordinateRegion?
    @State private var isZoomedIn: Bool = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingParentCheckAlert = false
    @State private var navigateToCamera: Bool = false

    var body: some View {
        NavigationStack{
            VStack {
                Text("Take a walk with me!")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Map(position: $cameraPosition) {
                    if let userLocationWrapper = userLocationWrapper {
                        Marker("You are here", coordinate: userLocationWrapper.coordinate)
                            .tint(.blue)
                    }
                    
                    if !viewModel.walkingPath.isEmpty {
                        MapPolyline(coordinates: viewModel.walkingPath)
                            .stroke(.red, lineWidth: 3)
                    }
                }.frame(maxHeight: .infinity)
                .mapStyle(.standard)
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .onMapCameraChange(frequency: .continuous) { context in
                    currentRegion = context.region
                    let zoomThreshold = 0.005
                    let newZoomState = context.region.span.latitudeDelta < zoomThreshold
                    if newZoomState != isZoomedIn {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isZoomedIn = newZoomState
                        }
                    }
                }
                
                HStack(spacing: 15) {
                    Button("Find My Location") {
                        viewModel.requestLocation()
                    }
                    .padding()
                    .background(isZoomedIn ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted)
                    
                    Button(viewModel.isWalking ? "Stop Walking" : "Start Walking") {
                        if viewModel.isWalking {
                            // Check if user is logged in before stopping
                            guard Auth.auth().currentUser != nil else {
                                alertMessage = "Please log in to save your walk data."
                                showingAlert = true
                                return
                            }
                            
                            viewModel.stopWalking()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                let walk = viewModel.saveWalkModel()
                                print("About to save walk: Distance=\(walk.distance), Duration=\(walk.duration), UserID=\(walk.userId)")
                                walkViewModel.createWalking(walk: walk)
                            }
                        } else {
                            guard Auth.auth().currentUser != nil else {
                                alertMessage = "Please log in to track your walks."
                                showingAlert = true
                                return
                            }
                            
                            // Check if parent verification is required
                            if !agePredictionViewModel.isParentPresent {
                                showingParentCheckAlert = true
                                return
                            }
                            
                            // If parent is verified, start walking
                            viewModel.startWalking()
                        }
                    }
                    .padding()
                    .background(getWalkingButtonColor())
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted)
                    .overlay(
                        // Add a subtle glow effect when parent is verified
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(agePredictionViewModel.isParentPresent && !viewModel.isWalking ? Color.green : Color.clear, lineWidth: 2)
                            .opacity(agePredictionViewModel.isParentPresent && !viewModel.isWalking ? 0.8 : 0)
                            .animation(.easeInOut(duration: 0.3), value: agePredictionViewModel.isParentPresent)
                    )
                }
                
                // Parent verification status indicator
                if agePredictionViewModel.predictionResult != "No prediction yet" {
                    HStack {
                        Image(systemName: agePredictionViewModel.isParentPresent ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(agePredictionViewModel.isParentPresent ? .green : .orange)
                        
                        Text(agePredictionViewModel.isParentPresent ? "Parent verified - Ready to walk!" : "Parent verification required")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(agePredictionViewModel.isParentPresent ? .green : .orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(agePredictionViewModel.isParentPresent ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    )
                    .animation(.easeInOut(duration: 0.3), value: agePredictionViewModel.isParentPresent)
                }
                
                VStack(spacing: 10) {
                    if viewModel.isWalking || viewModel.walkingDistance > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Walking Stats:")
                                .font(.headline)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Distance:")
                                        .font(.caption)
                                    Text("\(String(format: "%.1f", viewModel.walkingDistance)) m")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("Duration:")
                                        .font(.caption)
                                    Text(formatDuration(viewModel.walkingDuration))
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            if viewModel.isWalking {
                                HStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                    Text("Walking...")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                }
            }
            .padding()
            .alert("Authentication Required", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .alert("Parent Verification Required", isPresented: $showingParentCheckAlert) {
                Button("Verify Now") {
                    navigateToCamera = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("For your safety, please verify that a parent or guardian is with you before starting your walk.")
            }
            .onReceive(viewModel.$userLocation) { location in
                if let loc = location {
                    let coord = loc.coordinate
                    userLocationWrapper = LocationModel(coordinate: coord)
                    withAnimation(.easeInOut(duration: 1.0)) {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: coord,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        )
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToCamera) {
                CameraView(viewModel: agePredictionViewModel)
            }
        }
        
        .onAppear {
            viewModel.requestLocation()
        }
    }
    
    private func getWalkingButtonColor() -> Color {
        if viewModel.isWalking {
            return .red
        } else if agePredictionViewModel.isParentPresent {
            return .green // Green when parent is verified and ready to walk
        } else {
            return .orange // Orange when parent verification is needed
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    MapView()
        .environmentObject(LocationViewModel())
}
