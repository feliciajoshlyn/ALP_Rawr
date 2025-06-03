//
//  DiaryViewModel.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import Foundation
import WatchConnectivity

class DiaryViewModel : ObservableObject{
    let diaryService : DiaryServiceProtocol
//    var session: WCSession
    
    @Published var diary: [DiaryEntry] = []
    @Published var friends: [MyUser] = []
    @Published var searchedFriend: MyUser? = nil
    @Published var userReactions: [String: Reaction] = [:]
    
    
    @Published var isLoading = false
    
//    private let diaryService = DiaryService.shared
    
    init(diaryService :DiaryServiceProtocol = DiaryService.shared) {
//        self.session = session
        self.diaryService = diaryService
//        super.init()
//        session.delegate = self
//        session.activate()
    }
    
    func loadEntries(for userId: String) {
        isLoading = true
        
        diaryService.fetchFriends(userId: userId) { friends in
            self.diaryService.fetchDiaryWithFriends(userId: userId, friends: friends) { entries in
                DispatchQueue.main.async {
                    self.diary = entries
                    self.isLoading = false
                }
            }
        }
    }
    
    func addEntry(_ entry: DiaryEntry) {
        diaryService.addDiaryEntry(entry: entry) { success in
            DispatchQueue.main.async {
                if success {
                    print("Diary Entry added Successfully")
                } else {
                    print("Failed to add Diary Entry")
                }
            }
        }
    }
    
//    func loadReaction(for entryId: String, userId : String) {
//        diaryService.fetchReaction(for: entryId, userId: userId) { reaction in
//            DispatchQueue.main.async {
//                if let reaction = reaction {
//                    self.userReactions[entryId] = reaction
//                } else {
//                    self.userReactions[entryId] = nil
//                }
//            }
//        }
//    }
    
    //    func loadReactions(for entryId: String) {
    //        diaryService.fetchReactions(toEntryId: entryId) { reactions in
    //            DispatchQueue.main.async {
    //                if let index = self.diary.firstIndex(where: { $0.id == entryId }) {
    //                    self.diary[index].reactions = reactions
    //                }
    //            }
    //        }
    //    }
    
//    func loadReactions(for entryId: String) {
//        diaryService.fetchReactions(toEntryId: entryId) { reactions in
//            DispatchQueue.main.async {
//                if let index = self.diary.firstIndex(where: { $0.id == entryId }) {
//                    var updatedEntry = self.diary[index]
//                    updatedEntry.reactions = reactions
//                    self.diary[index] = updatedEntry
//                }
//            }
//        }
//    }
    
    
//    func addReaction(to entryId: String, _ reaction: Reaction) {
//        diaryService.addOrUpdateReaction(toEntryId: entryId, reaction: reaction) {success in
//            if success {
//                print("Successfully added reaction")
//            } else {
//                print("Failed to add reaction")
//            }
//        }
//    }
    
    //    func addFriend(from currentUserId: String, to friendId: String) {
    //        diaryService.addFriend(currentUserId: currentUserId, friendId: friendId) {success in
    //            if success {
    //                print( "Successfully added friend")
    //            } else {
    //                print( "Failed to add friend")
    //            }
    //        }
    //    }
    func searchFriend(by uid: String) {
        diaryService.searchUser(byUID: uid) { user in
            DispatchQueue.main.async {
                self.searchedFriend = user
            }
        }
    }
    
    
    func addFriendButtonAction(currentUserId: String, friendId: String) {
        diaryService.addMutualFriend(currentUserId: currentUserId, friendId: friendId) { success in
            DispatchQueue.main.async {
                if success {
                    print("Successfully added mutual friend")
                } else {
                    print("Failed to add mutual friend")
                }
            }
        }
    }
    
    func fetchCurrentUserFriends(currentUserId: String) {
        diaryService.fetchFriends(userId: currentUserId) { friendUIDs in
            var friends: [MyUser] = []
            let group = DispatchGroup()
            
            for uid in friendUIDs {
                group.enter()
                self.diaryService.searchUser(byUID: uid) { user in
                    if let user = user {
                        friends.append(user)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.friends = friends
            }
        }
    }
    
    
    func addMutualFriend(from currentUserId: String, to friendId: String) {
        diaryService.addMutualFriend(currentUserId: currentUserId, friendId: friendId) { success in
            if success {
                print("successfully added as friends")
            } else {
                print("failed to add as friends")
            }
        }
    }
    
    
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
//    
//    func sessionDidBecomeInactive(_ session: WCSession) {}
//    
//    func sessionDidDeactivate(_ session: WCSession) {}
//    
//    func sendDiarytoWatch() {
//        //make sure bsa connect ke watch dlu
//        guard WCSession.default.isReachable else {
//            print("Watch is not reachable")
//            return
//        }
//        
//        let diaryPayLoad = diary.map { entry in
//            return [
//                "id": entry.id,
//                "userId": entry.userId,
//                "title": entry.title,
//                "text": entry.text,
//                "createdAt": entry.createdAt.timeIntervalSince1970
//            ]
//        }
//        
//        let dataToSend: [String: Any] = ["diaryEntries": diaryPayLoad]
//        
//        self.session.sendMessage(dataToSend, replyHandler: { response in
//            print("Watch replied: \(response)")
//        }, errorHandler: { error in
//            print("failed to send message : \(error)")
//        })
//    }
//    
//    func sendFriendstoWatch() {
//        guard WCSession.default.isReachable else {
//            print("Watch is not reachable")
//            return
//        }
//        
//        let friendPayLoad = friends.map { friend in
//            return [
//                "uid": friend.id,
//                "username": friend.username,
//                ]
//            }
//        let dataToSend: [String: Any] = ["friends": friendPayLoad]
//        
//        self.session.sendMessage(dataToSend, replyHandler: { response in
//            print("Watch replied: \(response)")
//        }, errorHandler: { error in
//            print("failed to send message : \(error)")
//        })
//    }
//    
//    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
//        if let action = message["action"] as? String {
//            switch action {
//            case "searchFriend":
//                if let uid = message["uid"] as? String {
//                    diaryService.searchUser(byUID: uid) { user in
//                        if let user = user {
//                            replyHandler([
//                                "status": "success",
//                                "username": user.username
//                            ])
//                        } else {
//                            replyHandler(["status": "not_found"])
//                        }
//                    }
//                }
//                
//            case "addFriend":
//                if let userId = message["userId"] as? String,
//                   let friendId = message["friendId"] as? String {
//                    diaryService.addMutualFriend(currentUserId: userId, friendId: friendId) { success in
//                        replyHandler(["status": success ? "success" : "failed"])
//                    }
//                }
//                
//            default:
//                replyHandler(["status": "unknown_action"])
//            }
//        } else {
//            replyHandler(["status": "no_action"])
//        }
//    }
}
