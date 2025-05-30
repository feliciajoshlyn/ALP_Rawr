//
//  PetModel.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import Foundation

struct PetModel: Codable {
    var name: String = ""
    var hp: Double = 100.0
    var hunger: Double = 100.0
    var isHungry: Bool = false
    var bond: Double = 0.0
    var lastFed: Date = Date()
    var lastPetted: Date = Date()
    var lastWalked: Date = Date()
    var lastShower: Date = Date()
    var lastChecked: Date = Date()
    var currMood: String = "Happy"
    var emotions: [String:PetEmotionModel] = [:]
    var userId: String = ""
    
    // Custom date formatter
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    // Custom encoding for dates
    enum CodingKeys: String, CodingKey {
        case name, hp, hunger, isHungry, bond, currMood, emotions, userId
        case lastFed, lastPetted, lastWalked, lastShower, lastChecked
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(hp, forKey: .hp)
        try container.encode(hunger, forKey: .hunger)
        try container.encode(isHungry, forKey: .isHungry)
        try container.encode(bond, forKey: .bond)
        try container.encode(currMood, forKey: .currMood)
        try container.encode(emotions, forKey: .emotions)
        try container.encode(userId, forKey: .userId)
        
        // Encode dates as strings
        try container.encode(Self.dateFormatter.string(from: lastFed), forKey: .lastFed)
        try container.encode(Self.dateFormatter.string(from: lastPetted), forKey: .lastPetted)
        try container.encode(Self.dateFormatter.string(from: lastWalked), forKey: .lastWalked)
        try container.encode(Self.dateFormatter.string(from: lastShower), forKey: .lastShower)
        try container.encode(Self.dateFormatter.string(from: lastChecked), forKey: .lastChecked)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        hp = try container.decode(Double.self, forKey: .hp)
        hunger = try container.decode(Double.self, forKey: .hunger)
        isHungry = try container.decode(Bool.self, forKey: .isHungry)
        bond = try container.decode(Double.self, forKey: .bond)
        currMood = try container.decode(String.self, forKey: .currMood)
        emotions = try container.decode([String:PetEmotionModel].self, forKey: .emotions)
        userId = try container.decode(String.self, forKey: .userId)
        
        // Decode dates from strings
        let lastFedString = try container.decode(String.self, forKey: .lastFed)
        let lastPettedString = try container.decode(String.self, forKey: .lastPetted)
        let lastWalkedString = try container.decode(String.self, forKey: .lastWalked)
        let lastShowerString = try container.decode(String.self, forKey: .lastShower)
        let lastCheckedString = try container.decode(String.self, forKey: .lastChecked)
        
        lastFed = Self.dateFormatter.date(from: lastFedString) ?? Date()
        lastPetted = Self.dateFormatter.date(from: lastPettedString) ?? Date()
        lastWalked = Self.dateFormatter.date(from: lastWalkedString) ?? Date()
        lastShower = Self.dateFormatter.date(from: lastShowerString) ?? Date()
        lastChecked = Self.dateFormatter.date(from: lastCheckedString) ?? Date()
    }
    
    init(name: String = "",
         hp: Double = 100,
         hunger: Double = 100,
         isHungry: Bool = false,
         bond: Double = 0,
         lastFed: Date = Date(),
         lastPetted: Date = Date(),
         lastWalked: Date = Date(),
         lastShower: Date = Date(),
         lastChecked: Date = Date(),
         currMood: String = "Happy",
         emotions: [String:PetEmotionModel] = [:],
         userId: String = "") {
        
        self.name = name
        self.hp = hp
        self.hunger = hunger
        self.isHungry = isHungry
        self.bond = bond
        self.lastFed = lastFed
        self.lastPetted = lastPetted
        self.lastWalked = lastWalked
        self.lastShower = lastShower
        self.lastChecked = lastChecked
        self.currMood = currMood
        self.emotions = emotions
        self.userId = userId
    }
}
