//
//  Entry.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import Foundation
import FirebaseFirestore

struct DiaryEntry: Identifiable {
    let id: String
    let userId: String
    let text: String
    let createdAt: Timestamp
    
    var reactions: [Reaction]? = []
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.userId = data["userId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
    }
}

extension DiaryEntry {
    var likesCount: Int {
        reactions?.filter { $0.isLiked }.count ?? 0
    }
}
