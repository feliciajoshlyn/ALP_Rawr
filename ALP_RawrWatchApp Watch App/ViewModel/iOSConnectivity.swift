//
//  iOSConnectivity.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by student on 30/05/25.
//

import Foundation
import WatchConnectivity

//Handle connectivity di watchOSnya
public class iOSConnectivity: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var isParentVerified: Bool = false
    @Published var isWalking: Bool = false
    @Published var walkingStarted: Bool = false
    @Published var walkingDistance: Double = 0.0
    @Published var walkingDuration: TimeInterval = 0.0
    
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
                "type": InteractionType.petting
            ]
            session.sendMessage(dataToSend, replyHandler: { response in
                print("Pet message reply: \(response)")
            }){ error in
                print("Error sending pet message: \(error.localizedDescription)")
            }
        } else {
            print("Session is not reachable for petting")
        }
    }
    
    func sendFeedToiOS(){
        if session.isReachable {
            let dataToSend: [String : Any] = [
                "type": InteractionType.feeding
            ]
            session.sendMessage(dataToSend, replyHandler: { response in
                print("Feed message reply: \(response)")
            }){ error in
                print("Error sending feed message: \(error.localizedDescription)")
            }
        } else {
            print("Session is not reachable for feeding")
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
