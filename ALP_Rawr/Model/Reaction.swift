//
//  Reaction.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import Foundation
import FirebaseFirestore

struct Reaction : Identifiable {
    let id : String
    let userId: String
    let isLiked: Bool
    let comment: String?
    let createdAt: Timestamp
    
    init(id: String, data : [String: Any]) {
        self.id = id
        self.userId = data["userId"] as! String
        self.isLiked = data["liked"] as! Bool
        self.comment = data["comment"] as? String
        self.createdAt = data["createdAt"] as! Timestamp
    }
}
