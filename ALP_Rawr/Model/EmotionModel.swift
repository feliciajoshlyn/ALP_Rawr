//
//  EmotionModel.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import Foundation

struct EmotionModel: Codable {
    let name: String
    var level: Int
    let limit: Int
    let priority: Int
    let icon: String
    
    var isActive: Bool {
        return level >= limit
    }
}
