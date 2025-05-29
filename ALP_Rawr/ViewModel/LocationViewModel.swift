//
//  File.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 23/05/25.
//

import Foundation
import CoreLocation
import MapKit
import Combine

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isWalking: Bool = false
    @Published var walkingPath: [CLLocationCoordinate2D] = []
    @Published var walkingDistance: Double = 0.0
    @Published var walkingDuration: TimeInterval = 0.0

    private var walkStartTime: Date?
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
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

    func startWalking() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocation()
            return
        }

        isWalking = true
        walkStartTime = Date()
        walkingPath.removeAll()
        walkingDistance = 0.0
        walkingDuration = 0.0
        lastLocation = nil

        manager.startUpdatingLocation()
    }

    func stopWalking() {
        isWalking = false
        manager.stopUpdatingLocation()

        if let startTime = walkStartTime {
            walkingDuration = Date().timeIntervalSince(startTime)
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
