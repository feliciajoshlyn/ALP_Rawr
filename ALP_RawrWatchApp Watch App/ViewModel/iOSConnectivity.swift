//
//  iOSConnectivity.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by student on 30/05/25.
//

import Foundation
import Combine
import WatchConnectivity

//Handle connectivity di watchOSnya
public class iOSConnectivity: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var isParentVerified: Bool = false
    @Published var isWalking: Bool = false
    @Published var walkingStarted: Bool = false
    @Published var walkingDistance: Double = 0.0
    @Published var walkingDuration: TimeInterval = 0.0
    
    @Published var pet: PetModel = PetModel()
    
    var session: WCSession
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("Watch connectivity activated with state: \(activationState.rawValue)")
        if let error = error {
            print("Watch connectivity activation error: \(error.localizedDescription)")
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("Watch received message: \(message)")
            
            if let parentVerified = message["isParentVerified"] as? Bool {
                self.isParentVerified = parentVerified
                print("Parent verification status updated: \(parentVerified)")
            }
            
            if let walking = message["isWalking"] as? Bool {
                self.isWalking = walking
                print("Walking status updated: \(walking)")
            }
            
            // Handle walking data updates
            if let distance = message["walkingDistance"] as? Double {
                self.walkingDistance = distance
                print("Walking distance updated on watch: \(distance)")
            }
            
            if let duration = message["walkingDuration"] as? TimeInterval {
                self.walkingDuration = duration
                print("Walking duration updated on watch: \(duration)")
            }
            
            // Handle walking started confirmation
            if let walkingStarted = message["walkingStarted"] as? Bool {
                self.walkingStarted = walkingStarted
                print("Walking started confirmation: \(walkingStarted)")
            }
            
            // Handle walking stopped confirmation
            if let walkingStopped = message["walkingStopped"] as? Bool, walkingStopped {
                self.isWalking = false
                print("Walking stopped confirmation received on watch")
            }
        }
    }
    
    func sendPetToiOS(){
        if session.isReachable {
            let dataToSend: [String : Any] = [
                "type": "petting"
            ]
            session.sendMessage(dataToSend, replyHandler: nil){ error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }else{
            print("Session is not reachable")
        }
    }
    
    func sendFeedToiOS(){
        print("Attempting to send feed message...")
        print("Session state - isReachable: \(session.isReachable), activationState: \(session.activationState.rawValue)")
        
        if session.isReachable {
            let dataToSend: [String : Any] = [
                "type": "feeding"
            ]
            print("Sending message: \(dataToSend)")
            session.sendMessage(dataToSend, replyHandler: { reply in
                print("Received reply: \(reply)")
            }){ error in
                print("Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("Session is not reachable")
        }
    }
    
    func fetchPetFromiOS(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let petDict = message["petData"] else {
            print("No pet data received")
            return
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: petDict)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // Same as encoder
            let pet = try decoder.decode(PetModel.self, from: jsonData)
            
            // Do something with the decoded pet
            print("Received pet: \(pet.name), hunger: \(pet.hunger)")
            
            // e.g., update view model or @Published pet property
            DispatchQueue.main.async {
                self.pet = pet
            }

        } catch {
            print("Error decoding pet model: \(error)")
        }
    }
    
    func sendWalkToiOS(){
        if session.isReachable {
            let dataToSend: [String : Any] = [
                "type": "walking",
                "startWalking": true
            ]
            
            print("Sending walk request to iOS...")
            session.sendMessage(dataToSend, replyHandler: { response in
                DispatchQueue.main.async {
                    print("Walk message reply: \(response)")
                    if let walkingStarted = response["walkingStarted"] as? Bool {
                        self.walkingStarted = walkingStarted
                        self.isWalking = walkingStarted
                    }
                }
            }){ error in
                print("Error sending walk message: \(error.localizedDescription)")
            }
        } else {
            print("Session is not reachable for walking")
        }
    }
    
    func sendStopWalkingToiOS(){
        if session.isReachable {
            let dataToSend: [String : Any] = [
                "type": "walking",
                "stopWalking": true
            ]
            
            print("Sending stop walking request to iOS...")
            session.sendMessage(dataToSend, replyHandler: { response in
                DispatchQueue.main.async {
                    print("Stop walking message reply: \(response)")
                    if let walkingStopped = response["walkingStopped"] as? Bool, walkingStopped {
                        self.isWalking = false
                    }
                }
            }){ error in
                print("Error sending stop walking message: \(error.localizedDescription)")
            }
        } else {
            print("Session is not reachable for stopping walking")
        }
    }
}
