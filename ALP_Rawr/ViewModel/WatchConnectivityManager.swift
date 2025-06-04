//
//  WatchConnectivityManager.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 01/06/25.
//

import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, @preconcurrency WCSessionDelegate, ObservableObject {
    
    static let shared = WatchConnectivityManager()
    
    // Published property to trigger navigation
    @Published var shouldShowCameraView = false
    
#if os(iOS)
    var locationVM: LocationViewModel?
    var agePredictionVM: AgePredictionViewModel?
    var walkingVM: WalkingViewModel?
    var petHomeVM: PetHomeViewModel?
    var diaryVM: DiaryViewModel?
    
    // Combine cancellables to observe view model changes
    private var cancellables = Set<AnyCancellable>()
    
    // Timer for regular walking data updates
    private var walkingDataTimer: Timer?
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
            .sink { [weak self] isWalking in
                self?.sendStatusToWatch()
                
                // Start or stop the walking data timer based on walking state
                if isWalking {
                    self?.startWalkingDataTimer()
                } else {
                    self?.stopWalkingDataTimer()
                }
            }
            .store(in: &cancellables)
        
        // Observe walking distance for immediate updates
        locationVM?.$walkingDistance
            .removeDuplicates()
            .sink { [weak self] distance in
                print("LocationVM walking distance changed: \(distance)")
                // Only send immediate update if not relying on timer
                if self?.walkingDataTimer == nil {
                    self?.sendWalkingDataToWatch()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func startWalkingDataTimer() {
        // Stop any existing timer
        stopWalkingDataTimer()
        
        // Send initial data immediately
        sendWalkingDataToWatch()
        
        // Start timer to send updates every second
        walkingDataTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sendWalkingDataToWatch()
        }
        
        print("Started walking data timer for Watch synchronization")
    }
    
    @MainActor
    private func stopWalkingDataTimer() {
        walkingDataTimer?.invalidate()
        walkingDataTimer = nil
        print("Stopped walking data timer")
    }
#endif
    
    @MainActor
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("Session with watch connected to WatchConnectivityManager")
//        if activationState == .activated && session.isReachable {
//            self.sendPetToWatch(pet: petHomeVM?.pet ?? PetModel())
//        }
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) { }
#endif
    
private var hasInjected = false
    
#if os(iOS)
@MainActor
func injectViewModels(
    locationVM: LocationViewModel,
    agePredictionVM: AgePredictionViewModel,
    walkingVM: WalkingViewModel,
    petHomeVM: PetHomeViewModel,
    diaryVM: DiaryViewModel
) {
    guard !hasInjected else { return }
    hasInjected = true

    self.locationVM = locationVM
    self.agePredictionVM = agePredictionVM
    self.walkingVM = walkingVM
    self.petHomeVM = petHomeVM
    self.diaryVM = diaryVM

    setupViewModelObservers()
}
#endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
#if os(iOS)
            if let messageType = message["type"] as? String {
                switch messageType {
                case "petting":
                    print("Received petting request from watch")
                    self.petHomeVM?.applyInteraction(.petting)
                    replyHandler(["success": true])
                    
                case "feeding":
                    print("Received feeding request from watch")
                    self.petHomeVM?.applyInteraction(.feeding)
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
                    
                case "syncDiary":
                    self.sendDiaryToWatch()
                    replyHandler(["status": "diary_sent"])
                    
                case "syncFriends":
                    self.sendFriendsToWatch()
                    replyHandler(["status": "friends_sent"])

                case "searchFriend":
                    if let uid = message["uid"] as? String {
                        self.diaryVM?.diaryService.searchUser(byUID: uid) { user in
                            if let user = user {
                                replyHandler([
                                    "status": "success",
                                    "username": user.username
                                ])
                            } else {
                                replyHandler(["status": "not_found"])
                            }
                        }
                    } else {
                        replyHandler(["status": "invalid_uid"])
                    }

                case "addFriend":
                    if let userId = message["userId"] as? String,
                       let friendId = message["friendId"] as? String {
                        self.diaryVM?.diaryService.addMutualFriend(currentUserId: userId, friendId: friendId) { success in
                            replyHandler(["status": success ? "success" : "failed"])
                        }
                    } else {
                        replyHandler(["status": "invalid_params"])
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
        
        // Send final walking data to watch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.sendWalkingDataToWatch()
        }
        
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
        
        print("Sending walking data to watch: Distance=\(locationVM.walkingDistance), Duration=\(locationVM.walkingDuration)")
        WCSession.default.sendMessage(walkingData, replyHandler: nil) { error in
            print("Error sending walking data to watch: \(error.localizedDescription)")
        }
    }
#endif
    
#if os(iOS)
@MainActor
func sendDiaryToWatch() {
    guard WCSession.default.isReachable else {
        print("Watch is not reachable")
        return
    }
    
    guard let diary = diaryVM?.diary else { return }

    let diaryPayload = diary.map { entry in
        return [
            "id": entry.id,
            "userId": entry.userId,
            "title": entry.title,
            "text": entry.text,
            "createdAt": entry.createdAt.timeIntervalSince1970
        ]
    }
    
    let dataToSend: [String: Any] = ["diaryEntries": diaryPayload]
    
    WCSession.default.sendMessage(dataToSend, replyHandler: { response in
        print("Watch replied to diary: \(response)")
    }, errorHandler: { error in
        print("Failed to send diary: \(error)")
    })
}

@MainActor
func sendFriendsToWatch() {
    guard WCSession.default.isReachable else {
        print("Watch is not reachable")
        return
    }
    
    guard let friends = diaryVM?.friends else { return }

    let friendPayload = friends.map { friend in
        return [
            "uid": friend.id,
            "username": friend.username
        ]
    }
    
    let dataToSend: [String: Any] = ["friends": friendPayload]
    
    WCSession.default.sendMessage(dataToSend, replyHandler: { response in
        print("Watch replied to friends: \(response)")
    }, errorHandler: { error in
        print("Failed to send friends: \(error)")
    })
}

@MainActor
func sendPetToWatch(pet: PetModel) {
    guard WCSession.default.isReachable else {
        print("Watch is not reachable.")
        return
    }

    do {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Match decoding strategy on the Watch
        let data = try encoder.encode(pet)
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            WCSession.default.sendMessage(["petData": json], replyHandler: nil) { error in
                print("Error sending petData: \(error.localizedDescription)")
            }
        }
    } catch {
        print("Failed to encode PetModel: \(error)")
    }
}

    
#endif

}
