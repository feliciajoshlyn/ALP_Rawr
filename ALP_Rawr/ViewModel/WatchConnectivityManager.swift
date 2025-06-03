//
//  WatchConnectivityManager.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 01/06/25.
//

import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = WatchConnectivityManager()
    
    // Published property to trigger navigation
    @Published var shouldShowCameraView = false
    
#if os(iOS)
    var locationVM: LocationViewModel?
    var agePredictionVM: AgePredictionViewModel?
    var walkingVM: WalkingViewModel?
    
    // Combine cancellables to observe view model changes
    private var cancellables = Set<AnyCancellable>()
#endif
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
#if os(iOS)
    @MainActor
    func setupViewModelObservers() {
        agePredictionVM?.$predictionResult
            .map { result in
                result == "20-29" || result == "30-39" ||
                result == "40-49" || result == "50-59" ||
                result == "60-69" || result == "more than 70"
            }
            .removeDuplicates()
            .sink { [weak self] isParentPresent in
                if isParentPresent {
                    self?.sendStatusToWatch()
                    // Hide camera view
                    self?.shouldShowCameraView = false
                }
            }
            .store(in: &cancellables)
        
        // Observe walking state changes
        locationVM?.$isWalking
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.sendStatusToWatch()
            }
            .store(in: &cancellables)
        
        // Observe walking distance and duration for real-time updates
        locationVM?.$walkingDistance
            .removeDuplicates()
            .sink { [weak self] distance in
                print("LocationVM walking distance changed: \(distance)")
                self?.sendWalkingDataToWatch()
            }
            .store(in: &cancellables)
        
        locationVM?.$walkingDuration
            .removeDuplicates()
            .sink { [weak self] duration in
                print("LocationVM walking duration changed: \(duration)")
                self?.sendWalkingDataToWatch()
            }
            .store(in: &cancellables)
    }
#endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        //
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) { }
#endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
#if os(iOS)
            if let messageType = message["type"] as? String {
                switch messageType {
                case "petting":
                    print("Received petting request from watch")
                    replyHandler(["success": true])
                    
                case "feeding":
                    print("Received feeding request from watch")
                    replyHandler(["success": true])
                    
                case "walking":
                    if let startWalking = message["startWalking"] as? Bool, startWalking == true {
                        if self.agePredictionVM?.isParentPresent == true {
                            self.locationVM?.startWalking()
                            replyHandler(["walkingStarted": true])
                            print("Walking started from watch request")
                            
                            // Send initial walking data immediately
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.sendWalkingDataToWatch()
                            }
                        } else {
                            self.shouldShowCameraView = true
                            replyHandler(["walkingStarted": false, "needsParentVerification": true])
                            print("Parent verification required for walking")
                        }
                    } else if let stopWalking = message["stopWalking"] as? Bool, stopWalking == true {
                        self.stopWalkingAndSave()
                        replyHandler(["walkingStopped": true])
                        print("Walking stopped from watch request")
                    }
                    
                default:
                    print("Unknown message type: \(messageType)")
                    replyHandler(["error": "Unknown message type"])
                }
            } else {
                // Legacy support for direct startWalking messages
                if let request = message["startWalking"] as? Bool, request == true {
                    if self.agePredictionVM?.isParentPresent == true {
                        self.locationVM?.startWalking()
                        replyHandler(["walkingStarted": true])
                    } else {
                        self.shouldShowCameraView = true
                        replyHandler(["walkingStarted": false, "needsParentVerification": true])
                    }
                } else {
                    replyHandler(["error": "Invalid message format"])
                }
            }
#endif
        }
    }
    
    // Fallback for messages without reply handler
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //
    }
    
#if os(iOS)
    @MainActor
    private func stopWalkingAndSave() {
        guard let locationVM = locationVM, let walkingVM = walkingVM else { return }
        
        locationVM.stopWalking()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let walk = locationVM.saveWalkModel()
            print("Saving walk from watch: Distance=\(walk.distance), Duration=\(walk.duration), UserID=\(walk.userId)")
            walkingVM.createWalking(walk: walk)
        }
    }
    
    @MainActor
    func sendStatusToWatch() {
        guard WCSession.default.isReachable else { return }
        
        let isParentPresent = agePredictionVM?.isParentPresent ?? false
        let predictionResult = agePredictionVM?.predictionResult ?? "none"
        
        print("DEBUG - Prediction result: '\(predictionResult)'")
        print("DEBUG - Is parent present: \(isParentPresent)")
        
        let status: [String: Any] = [
            "isParentVerified": isParentPresent,
            "isWalking": locationVM?.isWalking ?? false
        ]
        
        WCSession.default.sendMessage(status, replyHandler: nil) { error in
            print("Error sending status to watch: \(error.localizedDescription)")
        }
        print("Sent status to watch: \(status)")
    }
    
    @MainActor
    func sendWalkingDataToWatch() {
        guard WCSession.default.isReachable,
              let locationVM = locationVM else {
            print("Cannot send walking data - session not reachable or locationVM nil")
            return
        }
        
        let walkingData: [String: Any] = [
            "walkingDistance": locationVM.walkingDistance,
            "walkingDuration": locationVM.walkingDuration,
            "isWalking": locationVM.isWalking
        ]
        
        print("Sending walking data to watch: \(walkingData)")
        WCSession.default.sendMessage(walkingData, replyHandler: nil) { error in
            print("Error sending walking data to watch: \(error.localizedDescription)")
        }
    }
#endif
}
