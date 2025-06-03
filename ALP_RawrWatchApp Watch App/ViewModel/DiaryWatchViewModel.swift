//
//  DiaryWatchViewModel.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by Gerald Gavin Lienardi on 31/05/25.
//

import Foundation
import WatchConnectivity

//Handle connectivity di watchOSnya
public class DiaryWatchViewModel: ObservableObject {
//    public func sessionDidBecomeInactive(_ session: WCSession) {
//        
//    }
//    
//    public func sessionDidDeactivate(_ session: WCSession) {
//        
//    }
    
//    private var session: WCSession
    
//    @Published var userId: String?
//    @Published var diary: [DiaryEntry] = [DiaryEntry(id: UUID().uuidString, data: ["userId": "123", "title": "Exercise", "text": "Did a 1.7km walk!", "createdAt": Date().timeIntervalSince1970])]
//    @Published var friends: [[String: Any]] = [["uid": "XiJw4ArY2PeJY7YjY2Y2", "username": "Yohana"]]
//    @Published var searchedFriend: [String: Any]? = nil
    
    init(){
//        self.session = session
//        super.init()
//        session.delegate = self
//        session.activate()
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
//    func fetchEntriesFromiOS(_ session: WCSession, didReceiveMessage message : [String: Any]) {
//        DispatchQueue.main.async {
//            //make sure it's diary data
//            guard let diaryData = message["diaryEntries"] as? [[String : Any]] else {
//                print("Invalid format / context")
//                return
//            }
//
//            self.diary = diaryData.compactMap { dict in
//                guard let id = dict["id"] as? String else {
//                    return nil
//                }
//                return DiaryEntry(id: id, data: dict)
//            }
//
//            print("Diary updated with \(self.diary.count) entries")
//        }
//    }
//    
//    func fetchFriendsFromiOS(_ session: WCSession, didReceiveMessage message : [String: Any]) {
//        DispatchQueue.main.async {
//            guard let friendsData = message["friends"] as? [[String : Any]] else {
//                print("Invalid format / context")
//                return
//            }
//            
//            self.friends = friendsData.compactMap { dict in
//                guard let uid = dict["uid"] as? String,
//                let username = dict["username"] as? String else {
//                    return nil
//                }
//                return ["uid": uid, "username": username]
//            }
//            
//            print("Friends updated with \(friendsData.count) entries")
//        }
//    }
//    
//    func fetchUserId(_ session: WCSession, didReceiveMessage message : [String: Any]) {
//        DispatchQueue.main.async {
//            guard let userId = message["userId"] as? String else {
//                print("Invalid format / context")
//                return
//            }
//            
//            self.userId = message["userId"] as? String
//            
//            print("userId fetched")
//        }
//    }
//    
//    func searchFriendFrom(uid: String) {
//        let message = ["action": "searchFriends", "uid": uid]
//        session.sendMessage(message, replyHandler: { reply in
//            if reply ["status"] as? String == "success" {
//                print("found username \(reply["username"] as! String)")
//                self.searchedFriend = [
//                    "uid": uid,
//                    "username": reply["username"] as! String
//                ]
//            }else {
//                print("user not found")
//            }
//        }, errorHandler: { error in
//            print("error fetching data")
//        })
//    }
//    
//    func addFriendFromWatch(friendId: String) {
//        let message = [
//            "action": "addFriend",
//            "userId": userId!,
//            "friendId": friendId
//        ]
//        
//        session.sendMessage(message, replyHandler: { reply in
//            print("added friend")
//        }, errorHandler: {error in
//            print("error adding friend")
//        })
//    }
    
    

    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        fetchEntriesFromiOS(session, didReceiveMessage: message)
//        fetchFriendsFromiOS(session, didReceiveMessage: message)
    }
}

