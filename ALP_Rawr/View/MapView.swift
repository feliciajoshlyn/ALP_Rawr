//
//  MapView.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 23/05/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @EnvironmentObject var viewModel: LocationViewModel
    @State private var userLocationWrapper: LocationModel? = nil
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -7.28352, longitude: 112.63169),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    @State private var currentRegion: MKCoordinateRegion?
    @State private var isZoomedIn: Bool = false

    var body: some View {
        NavigationStack{
            
            
            VStack {
                Map(position: $cameraPosition) {
                    // Fix the optional binding
                    if let userLocationWrapper = userLocationWrapper {
                        Marker("You are here", coordinate: userLocationWrapper.coordinate)
                            .tint(.blue)
                    }
                    
                    if !viewModel.walkingPath.isEmpty {
                        MapPolyline(coordinates: viewModel.walkingPath)
                            .stroke(.red, lineWidth: 3)
                    }
                }
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
                            viewModel.stopWalking()
                        } else {
                            viewModel.startWalking()
                        }
                    }
                    .padding()
                    .background(viewModel.isWalking ? Color.red : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted)
                }
                
                VStack(spacing: 10) {
                    if let region = currentRegion {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Map Info:")
                                .font(.headline)
                            Text("Center: \(String(format: "%.4f", region.center.latitude)), \(String(format: "%.4f", region.center.longitude))")
                                .font(.caption)
                            Text("Zoom: \(isZoomedIn ? "Zoomed In" : "Zoomed Out")")
                                .font(.caption)
                                .foregroundColor(isZoomedIn ? .green : .blue)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
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
                NavigationLink("Open Camera") {
                    CameraView()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .onReceive(viewModel.$userLocation) { location in
                if let loc = location {
                    let coord = loc.coordinate
                    userLocationWrapper = LocationModel(coordinate: coord) // This will now work
                    
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
        }
        .onAppear {
            viewModel.requestLocation()
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
