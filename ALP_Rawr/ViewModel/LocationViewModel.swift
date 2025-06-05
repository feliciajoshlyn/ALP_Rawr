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
    
    @Published var userLocation: CLLocation? // track current user location
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined // check user sudah allow location atau blm
    @Published var isWalking: Bool = false
    @Published var walkingPath: [CLLocationCoordinate2D] = []
    @Published var walkingDistance: Double = 0.0
    @Published var walkingDuration: TimeInterval = 0.0
    
    private var walkTimer: Timer?
    private var durationTimer: Timer? 
    @Published var startTime: Date?
    @Published var endTime: Date?
    @Published var walkStartTime: Date?
    
    // untuk simulasi, jadi user fake geraknya per index
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
    
    // ini untuk update pet punya waktu lastWalked
    func updatePetLastWalkedById(id: String) {
        let dbRef = Database.database().reference().child("pets")
        
        dbRef.observeSingleEvent(of: .value) { snapshot in
            guard let allPets = snapshot.value as? [String: [String: Any]] else { // cari semua data pet
                print("Failed to cast pet data or no pets found")
                return
            }
            
            var petFound = false
            // looping untuk semua petData yang ada di dbRef
            for (petId, petData) in allPets {
                if let userId = petData["userId"] as? String, userId == id { // masuk ke /pet yang userId = id
                    petFound = true
                    let lastWalkedString = ISO8601DateFormatter().string(from: self.endTime ?? Date())
                    dbRef.child(petId).child("lastWalked").setValue(lastWalkedString) { error, _ in
                        if let error = error {
                            print("Failed to update lastWalked: \(error.localizedDescription)")
                        } else {
                            print("Successfully updated lastWalked for pet belonging to user: \(userId)")
                        }
                    }
                    break
                }
            }
            
            if !petFound {
                print("Pet with userId: \(id) not found. Creating a default pet entry.")
            }
        }
    }
    

    func startWalking() {
        
        // Stop any existing timers first
        stopAllTimers() // cuma buat reset
        
        walkingPath = [] // kosongin path nya karena mau diisi yang baru
        walkingDistance = 0
        walkingDuration = 0
        isWalking = true
        simulatedIndex = 0
        
        let currentTime = Date()
        startTime = currentTime
        walkStartTime = currentTime
        lastLocation = nil
        
        print("Starting walk at: \(currentTime)")

        // Start simulation timer
        walkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // ini karena pake array jadi terbatas index nya, semisal sudah nilainya sama otomatis stopWalking
            guard self.simulatedIndex < self.simulatedPath.count else {
                DispatchQueue.main.async {
                    self.stopWalking()
                }
                return
            }

            let newCoord = self.simulatedPath[self.simulatedIndex] // newCoord untuk track current user location dengan index simulated jadi index dari array
            let newLocation = CLLocation(latitude: newCoord.latitude, longitude: newCoord.longitude) // update latitude dan longitude nya terus
            
            // update newLocation jadi userLocation
            DispatchQueue.main.async {
                self.userLocation = newLocation
            }

            // untuk hitung distance nya
            if let lastLoc = self.lastLocation {
                let distance = lastLoc.distance(from: newLocation)
                DispatchQueue.main.async {
                    self.walkingDistance += distance
                }
                print("Distance added: \(distance), Total: \(self.walkingDistance)")
            }

            // Add to path and update last location
            DispatchQueue.main.async {
                self.walkingPath.append(newCoord)
            }
            self.lastLocation = newLocation
            
            self.simulatedIndex += 1 // tiap 1 detik indextambah
        }
        
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // untuk update durasi tiap waktu 0.1 detik
            if let walkStart = self.walkStartTime {
                DispatchQueue.main.async {
                    self.walkingDuration = Date().timeIntervalSince(walkStart)
                }
            }
        }
    }

    func stopWalking() {
        
        stopAllTimers() // stop semua timer
        
        if simulatedIndex < simulatedPath.count {
            let finalCoord = simulatedPath[simulatedIndex]
            let finalLocation = CLLocation(latitude: finalCoord.latitude, longitude: finalCoord.longitude)
            
            // masukin semua calculation
            if let lastLoc = lastLocation {
                let distance = lastLoc.distance(from: finalLocation)
                walkingDistance += distance
                print("Final distance added: \(distance)")
            }
            
            walkingPath.append(finalCoord)
            userLocation = finalLocation
            lastLocation = finalLocation
        }

        
        if let walkStart = walkStartTime {
            walkingDuration = Date().timeIntervalSince(walkStart)
        }
        
        endTime = Date()
        isWalking = false
        
        print("Walk stopped - Distance: \(walkingDistance), Duration: \(walkingDuration)")
        print("Timer invalidated: walkTimer=\(walkTimer == nil), durationTimer=\(durationTimer == nil)")
        
        // Update pet's last walked time
        if let userId = Auth.auth().currentUser?.uid {
            self.updatePetLastWalkedById(id: userId)
        }
    }

    private func stopAllTimers() {
        walkTimer?.invalidate() // utk cancel
        walkTimer = nil // utk kasih isi nya = nil
        
        durationTimer?.invalidate()
        durationTimer = nil
        
        print("All timers stopped")
    }

    func saveWalkModel() -> WalkingModel {

        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in.")
            return WalkingModel()
        }
        
        print("Saving walk for user: \(userId)")
        print("Walk data - Distance: \(walkingDistance), Duration: \(walkingDuration)")
        
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
            notes: ""
        )
        
        return walkModel
    }

    // nah ini yang minta request authorization untuk location user di device
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
    
    //
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
