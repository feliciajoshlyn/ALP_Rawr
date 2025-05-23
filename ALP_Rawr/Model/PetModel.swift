//
//  PetModel.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import Foundation

struct PetModel: Codable {
    var name: String = ""
    var hp: Int = 100
    var isHungry: Bool = false
    var bond: Int = 0
    var lastFed: Date = Date()
    var lastPetted: Date = Date()
    var lastWalked: Date = Date()
    var currMood: String = "Happy"
    var emotions: [String:EmotionModel] = [:]
    var userId: String = ""
}
