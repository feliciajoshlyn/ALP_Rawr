//
//  LocationViewModel.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 23/05/25.
//

import Foundation
import CoreLocation
import MapKit
import Combine
import FirebaseAuth
import FirebaseDatabase

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isWalking: Bool = false
    @Published var walkingPath: [CLLocationCoordinate2D] = []
    @Published var walkingDistance: Double = 0.0
    @Published var walkingDuration: TimeInterval = 0.0
    
    private var walkTimer: Timer?
    @Published var startTime: Date?
    @Published var endTime: Date?
    @Published var walkStartTime: Date?
    
    // For simulation
    private var simulatedIndex = 0
    private let simulatedPath: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: -7.28352, longitude: 112.63169),
        CLLocationCoordinate2D(latitude: -7.28348, longitude: 112.63170),
        CLLocationCoordinate2D(latitude: -7.28334, longitude: 112.63172),
        CLLocationCoordinate2D(latitude: -7.28328, longitude: 112.63174),
        CLLocationCoordinate2D(latitude: -7.28319, longitude: 112.63176),
        CLLocationCoordinate2D(latitude: -7.28304, longitude: 112.63172),
        CLLocationCoordinate2D(latitude: -7.28295, longitude: 112.63174),
        CLLocationCoordinate2D(latitude: -7.28288, longitude: 112.63176),
    ]
    
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }
    
    func updatePetLastWalkedById(id: String) {
            let dbRef = Database.database().reference().child("pets")
            
            dbRef.observeSingleEvent(of: .value) { snapshot in
                guard let allPets = snapshot.value as? [String: [String: Any]] else {
                    print("Failed to cast pet data")
                    return
                }
                
                for (petId, petData) in allPets {
                    if let userId = petData["userId"] as? String, userId == id {
                        let lastWalkedString = ISO8601DateFormatter().string(from: self.endTime ?? Date())
                        dbRef.child(petId).child("lastWalked").setValue(lastWalkedString) { error, _ in
                            if let error = error {
                                print("Failed to update lastWalked: \(error.localizedDescription)")
                            } else {
                                print("Successfully updated lastWalked for \(userId)")
                            }
                        }
                        return
                    }
                }
                
                print("Pet with id: \(id) not found.")
            }
        }

    
    func startWalking() {
        // Reset all values
        walkingPath = []
        walkingDistance = 0
        walkingDuration = 0
        isWalking = true
        simulatedIndex = 0
        
        // Use consistent time reference
        let currentTime = Date()
        startTime = currentTime
        walkStartTime = currentTime
        lastLocation = nil
        
        print("Starting walk at: \(currentTime)")

        walkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard self.simulatedIndex < self.simulatedPath.count else {
                self.stopWalking()
                return
            }

            let newCoord = self.simulatedPath[self.simulatedIndex]
            let newLocation = CLLocation(latitude: newCoord.latitude, longitude: newCoord.longitude)
            self.userLocation = newLocation

            // Calculate distance if we have a previous location
            if let lastLoc = self.lastLocation {
                let distance = lastLoc.distance(from: newLocation)
                self.walkingDistance += distance
                print("Distance added: \(distance), Total: \(self.walkingDistance)")
            }

            // Add to path and update last location
            self.walkingPath.append(newCoord)
            self.lastLocation = newLocation
            
            // Update duration
            if let walkStart = self.walkStartTime {
                self.walkingDuration = Date().timeIntervalSince(walkStart)
                print("Duration: \(self.walkingDuration)")
            }
            
            self.simulatedIndex += 1
        }
    }
    
    func stopWalking() {
        walkTimer?.invalidate()
        walkTimer = nil

        // Handle case where user stops before simulation completes
        if simulatedIndex < simulatedPath.count {
            let finalCoord = simulatedPath[simulatedIndex]
            let finalLocation = CLLocation(latitude: finalCoord.latitude, longitude: finalCoord.longitude)
            
            // Add final distance calculation
            if let lastLoc = lastLocation {
                let distance = lastLoc.distance(from: finalLocation)
                walkingDistance += distance
                print("Final distance added: \(distance)")
            }
            
            walkingPath.append(finalCoord)
            userLocation = finalLocation
            lastLocation = finalLocation
        }

        // Final duration calculation
        if let walkStart = walkStartTime {
            walkingDuration = Date().timeIntervalSince(walkStart)
        }
        
        endTime = Date()
        isWalking = false
        
        print("Walk stopped - Distance: \(walkingDistance), Duration: \(walkingDuration)")
        self.updatePetLastWalkedById(id: Auth.auth().currentUser?.uid ?? "")
    }

    // Save to walk model
    func saveWalkModel() -> WalkingModel {
        // Check if user is logged in
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in.")
            return WalkingModel()
        }
        
        print("Saving walk for user: \(userId)")
        
        let duration = walkingDuration
        let distance = walkingDistance
        let avgSpeed = duration > 0 ? distance / duration : 0

        let walkModel = WalkingModel(
            id: UUID().uuidString,
            userId: userId,
            startTime: walkStartTime ?? Date(),
            endTime: endTime ?? Date(),
            duration: duration,
            distance: distance,
            averageSpeed: avgSpeed,
            notes: nil
        )
        
        return walkModel
    }

    func requestLocation() {
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            print("Location access denied")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location
        
        if isWalking {
            walkingPath.append(location.coordinate)
            if let lastLoc = lastLocation {
                let distance = location.distance(from: lastLoc)
                if distance > 2.0 && distance < 100.0 {
                    walkingDistance += distance
                }
            }
            lastLocation = location
            
            if let startTime = walkStartTime {
                walkingDuration = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    
}
