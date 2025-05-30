//
//  EmotionModel.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import Foundation

struct PetEmotionModel: Codable {
    let name: String
    var level: Double
    let limit: Double
    let priority: Int
    let icon: String
    
    var isActive: Bool {
        return level >= limit
    }
    
    mutating func apply(change: Double){
        self.level = max(0.0, min(100.0, self.level + change))
    }
}
