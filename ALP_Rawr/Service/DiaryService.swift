//
//  DiaryViewModel.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import Foundation
import FirebaseFirestore

class DiaryService{
    static let shared = DiaryService()
    
    private let db = Firestore.firestore()
    private init() {}
    
    func fetchDiaryEntries(forUserId userId: String, completion: @escaping ([DiaryEntry]) -> Void){
        db.collection("diaryEntries")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    print("Error fetching diary entries: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                let entries = docs.map { DiaryEntry(id: $0.documentID, data: $0.data()) }
                completion(entries)
            }
    }
    
    func fetchDiaryWithFriends(userId: String, friends: [String], completion: @escaping ([DiaryEntry]) -> Void){
        let allIds = friends + [userId]
        db.collection("diaryEntries")
            .whereField("userId", in: allIds)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    print("Error fetching diary entries: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                let entries = docs.map { DiaryEntry(id: $0.documentID, data: $0.data()) }
                completion(entries)
            }
    }
    
    func addDiaryEntry(_entry : DiaryEntry, completion: @escaping (Bool) -> Void) {
        let data: [String: Any] = [
            "userId": _entry.userId,
            "text": _entry.text,
            "createdAt": _entry.createdAt
        ]
        
        db.collection("diaryEntries").addDocument(data: data) { error in
            if let error = error {
                print("Error adding diary entry: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
//    func addReaction(toEntryId entryId: String, reaction: Reaction, completion: @escaping(Bool) -> Void) {
//        guard !entryId.isEmpty else {
//            print("Invalid entryId: empty string")
//            completion(false)
//            return
//        }
//        let data: [String: Any] = [
//            "userId": reaction.userId,
//            "reaction": reaction.id,
//            "isLiked": reaction.isLiked,
//            "comment": reaction.comment ?? "",
//            "createdAt": reaction.createdAt
//        ]
//
//        db.collection("diaryEntries").document(entryId)
//            .collection("reactions")
//            .addDocument(data: data) { error in
//                if let error = error {
//                    print("Error adding reaction to diary entry: \(error.localizedDescription)")
//                    completion(false)
//                    return
//                }
//                completion(true)
//            }
//    }
//
//    
//    func fetchReactions(toEntryId entryId: String, completion: @escaping ([Reaction]) -> Void) {
//        guard !entryId.isEmpty else {
//            print("Invalid entryId: empty string")
//            completion([])
//            return
//        }
//        db.collection("diaryEntries").document(entryId)
//            .collection("reactions")
//            .order(by: "createdAt", descending: true)
//            .getDocuments { snapshot, error in
//                guard let docs = snapshot?.documents, error == nil else {
//                    print("Error fetching reactions: \(error?.localizedDescription ?? "Unknown error")")
//                    completion([])
//                    return
//                }
//                let reactions = docs.map { Reaction(id: $0.documentID, data: $0.data())}
//                completion(reactions)
//            }
//    }
    
    func searchUser(byEmail email: String, completion: @escaping (MyUser?) -> Void){
        db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments() { snapshot, error in
                guard let document = snapshot?.documents.first, error == nil else {
                    completion(nil)
                    return
                }
                let user = MyUser(uid: document.documentID)
                completion(user)
            }
    }
    
    func addFriend(currentUserId: String, friendId: String, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("users").document(currentUserId)
        userRef.updateData([
            "friends": FieldValue.arrayUnion([friendId])
        ]){ error in
            if let error = error {
                print("Error adding friend: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func fetchFriends(userId: String, completion: @escaping ([String]) -> Void){
        guard !userId.isEmpty else {
            print("Invalid userId: empty string")
            completion([])
            return
        }
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error fetching friends: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            let friendsIds = data["friends"] as? [String] ?? []
            completion(friendsIds)
        }
    }

}
