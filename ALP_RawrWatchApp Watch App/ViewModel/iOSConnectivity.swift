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
    var session: WCSession
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sendToIOS(data: PetModel){
        if session.isReachable {
            let dataToSend: [String : Any] = [:
//                "title": data.title,
//                "author": data.author,
//                "image": data.image,
//                "genre": data.genre
            ]
            session.sendMessage(dataToSend, replyHandler: nil){ error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }else{
            print("Session is not reachable")
        }
    }
}
