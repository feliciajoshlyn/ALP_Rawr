//
//  DiaryViewModel.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import Foundation
import FirebaseFirestore

class DiaryService : DiaryServiceProtocol{
    
    static let shared = DiaryService()
    
    private let db = Firestore.firestore()
    private init() {}
    
    //not used as now we use the fetchdiary with friends
//    func fetchDiaryEntries(forUserId userId: String, completion: @escaping ([DiaryEntry]) -> Void){
//        db.collection("diaryEntries")
//            .whereField("userId", isEqualTo: userId)
//            .order(by: "createdAt", descending: true)
//            .getDocuments { snapshot, error in
//                guard let docs = snapshot?.documents, error == nil else {
//                    print("Error fetching diary entries: \(error?.localizedDescription ?? "Unknown error")")
//                    completion([])
//                    return
//                }
//                let entries = docs.map { DiaryEntry(id: $0.documentID, data: $0.data()) }
//                completion(entries)
//            }
//    }
    
    //for the diary page, it would fetch the user and the user's friends entries to show
    func fetchDiaryWithFriends(userId: String, friends: [String], completion: @escaping ([DiaryEntry]) -> Void){
        let allIds = friends + [userId]
        //get the documents where the field userId has the user and the friends'
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
    
    // add diary entry for a user with title and text
    func addDiaryEntry(entry : DiaryEntry, completion: @escaping (Bool) -> Void) {
        let data: [String: Any] = [
            "userId": entry.userId,
            "title": entry.title,
            "text": entry.text,
            "createdAt": entry.createdAt.timeIntervalSince1970
        ]
        
        //put in the firestore, add a document
        db.collection("diaryEntries").addDocument(data: data) { error in
            if let error = error {
                print("Error adding diary entry: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    //for reactions not used for now
//    func addOrUpdateReaction(toEntryId entryId: String, reaction: Reaction, completion: @escaping(Bool) -> Void) {
//        guard !entryId.isEmpty else {
//            print("Invalid entryId: empty string")
//            completion(false)
//            return
//        }
//        
//        let data: [String: Any] = [
//            "userId": reaction.userId,
//            "reaction": reaction.id,
//            "isLiked": reaction.isLiked,
//            "comment": reaction.comment ?? "",
//            "createdAt": reaction.createdAt.timeIntervalSince1970
//        ]
//        
//        let reactionRef = db.collection("diaryEntries")
//            .document(entryId)
//            .collection("reactions")
//            .document(reaction.userId)
//        
//        reactionRef.setData(data, merge: true) { error in
//            if let error = error {
//                print("Error adding reaction: \(error.localizedDescription)")
//                completion(false)
//                return
//            }
//            completion(true)
//        }
//    }
//    
//    func fetchReaction(for entryId: String, userId: String, completion: @escaping(Reaction?) -> Void) {
//        guard !entryId.isEmpty else {
//            print("Invalid entryId: empty string")
//            completion(nil)
//            return
//        }
//        db.collection("diaryEntries").document(entryId)
//            .collection("reactions").document(userId)
//            .getDocument { document, error in
//                if let error = error {
//                    print("Error fetching reaction: \(error.localizedDescription)")
//                    completion(nil)
//                    return
//                }
//                if let document = document, document.exists, let data = document.data(){
//                    let reaction = Reaction(id: document.documentID, data: data)
//                    completion(reaction)
//                }else {
//                    completion(nil)
//                    //artinya no reactions yet
//                }
//            }
//    }
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
    
    //function for search user
    func searchUser(byUID uid: String, completion: @escaping (MyUser?) -> Void) {
        db.collection("users").document(uid).getDocument { document, error in
            guard let document = document, document.exists, error == nil,
                  let data = document.data(),
                  let username = data["username"] as? String else {
                completion(nil)
                return
            }
            
            let user = MyUser(uid: document.documentID, username: username)
            completion(user)
        }
    }


    
    func addMutualFriend(currentUserId: String, friendId: String, completion: @escaping (Bool) -> Void) {
        let user1Ref = db.collection("users").document(currentUserId)
        let user2Ref = db.collection("users").document(friendId)
        
        let batch = db.batch()
        
        batch.updateData(["friends": FieldValue.arrayUnion([friendId])], forDocument: user1Ref)
        batch.updateData(["friends": FieldValue.arrayUnion([currentUserId])], forDocument: user2Ref)
        
        batch.commit { error in
            completion(error == nil)
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
