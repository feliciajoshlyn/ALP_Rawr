//
//  CommentSuggestion.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import Foundation
import FirebaseFirestore

struct CommentSuggestion{
    let id: String
    let entryId: String
    let friendUid: String
    let suggestion: [String]
    let generatedAt: Timestamp
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.entryId = data["entryId"] as? String ?? ""
        self.friendUid = data["friendUid"] as? String ?? ""
        self.suggestion = data["suggestion"] as? [String] ?? []
        self.generatedAt = data["generatedAt"] as? Timestamp ?? Timestamp()
    }
}
