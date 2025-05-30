//
//  Entry.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import Foundation

struct DiaryEntry: Identifiable {
    let id: String
    let userId: String
    let text: String
    let createdAt: Date
    
    var reactions: [Reaction]? = []
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.userId = data["userId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        
        if let timestamp = data["createdAt"] as? Date {
            // If the data already stores Date (e.g., from watchOS side)
            self.createdAt = timestamp
        } else if let timestamp = data["createdAt"] as? TimeInterval {
            // If createdAt is saved as TimeInterval (Double, Unix time seconds)
            self.createdAt = Date(timeIntervalSince1970: timestamp)
        } else {
            // fallback to current date if no date found
            self.createdAt = Date()
        }
    }
}

extension DiaryEntry {
    var likesCount: Int {
        reactions?.filter { $0.isLiked }.count ?? 0
    }
}
