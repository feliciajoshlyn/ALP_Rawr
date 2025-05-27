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
    
    func fetchDiaryEntries(forTamagotchiId tamagotchiId: String, completion: @escaping ([DiaryEntry]) -> Void){
        db.collection("diaryEntries")
            .whereField("tamagotchiId", isEqualTo: tamagotchiId)
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
            "tamagotchiId": _entry.tamagotchiId,
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
    
    func addReaction(toEntryId entryId: String, reaction: Reaction, completion: @escaping(Bool) -> Void) {
        let data: [String: Any] = [
            "userId": reaction.userId,
            "reaction": reaction.id,
            "isLiked": reaction.isLiked,
            "comment": reaction.comment ?? "",
            "createdAt": reaction.createdAt
        ]
        
        db.collection("diaryEntries").document(entryId)
            .collection("reactions")
            .addDocument(data: data) { error in
            if let error = error {
                print("Error adding reaction to diary entry: \(error.localizedDescription)")
                completion(false)
                return
            }
        }
    }
    
    func fetchReactions(toEntryId entryId: String, completion: @escaping ([Reaction]) -> Void) {
        db.collection("diaryEntries").document(entryId)
            .collection("reactions")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    print("Error fetching reactions: \(error!.localizedDescription)")
                    completion([])
                    return
                }
                let reactions = docs.map { Reaction(id: $0.documentID, data: $0.data())}
                completion(reactions)
            }
    }
}
