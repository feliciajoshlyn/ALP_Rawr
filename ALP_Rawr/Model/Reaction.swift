//
//  Reaction.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import Foundation

struct Reaction: Identifiable {
    let id: String
    let userId: String
    let isLiked: Bool
    let comment: String?
    let createdAt: Date
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.userId = data["userId"] as? String ?? ""
        self.isLiked = data["liked"] as? Bool ?? false
        self.comment = data["comment"] as? String
        
        if let timeInterval = data["createdAt"] as? Double {
            self.createdAt = Date(timeIntervalSince1970: timeInterval)
        } else {
            self.createdAt = Date()
        }
    }
}
