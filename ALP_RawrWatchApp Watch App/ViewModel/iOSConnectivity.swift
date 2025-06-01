//
//  iOSConnectivity.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by student on 30/05/25.
//

import Foundation
import WatchConnectivity

//Handle connectivity di watchOSnya
public class PetWatchViewModel: NSObject, WCSessionDelegate, ObservableObject {
//    public func sessionDidBecomeInactive(_ session: WCSession) {
//        
//    }
//    
//    public func sessionDidDeactivate(_ session: WCSession) {
//        
//    }
    
    var session: WCSession
    @Published var pet: PetModel = PetModel()
        
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    func sendPetToiOS(){
        if session.isReachable {
            let dataToSend: [String : Any] = [
                "type": InteractionType.petting
            ]
            session.sendMessage(dataToSend, replyHandler: nil){ error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }else{
            print("Session is not reachable")
        }
    }
    
    func sendFeedToiOS(){
        if session.isReachable {
            let dataToSend: [String : Any] = [
                "type": InteractionType.feeding
            ]
            session.sendMessage(dataToSend, replyHandler: nil){ error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }else{
            print("Session is not reachable")
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        fetchPetFromiOS(session, didReceiveMessage: message)
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
}
