//
//  InteractionEffect.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import Foundation

struct InteractionEffect {
    static let effects: [InteractionType: [String: Int]] = [
        .petting: [
            "Happy": +10,
            "Sad": -8,
            "Angry": -6,
            "Bored": -4,
            "Fear": -10
        ],
        .feeding: [
            "Happy": +8,
            "Sad": -10,
            "Angry": -4,
            "Bored": -3,
            "Fear": -6
        ],
        .walking: [
            "Happy": +12,
            "Sad": -5,
            "Angry": -8,
            "Bored": -15,
            "Fear": -10
        ]
    ]
}
