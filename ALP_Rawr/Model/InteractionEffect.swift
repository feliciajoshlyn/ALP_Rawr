//
//  InteractionEffect.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import Foundation


struct InteractionEffect {
    static let effects: [InteractionType: [String: Double]] = [
        .petting: [
            "Happy": +6.0,      // Reduced from +10 - moderate happiness boost
            "Sad": -12.0,       // Stronger sad reduction - petting is very comforting
            "Angry": -8.0,      // Good for calming anger
            "Bored": -5.0,      // Slight boredom relief
            "Fear": -15.0       // Petting is very reassuring against fear
        ],
        .feeding: [
            "Happy": +5.0,      // Moderate happiness from food
            "Sad": -6.0,        // Food helps but doesn't cure sadness completely
            "Angry": -12.0,     // Being hangry is real - feeding fixes anger well
            "Bored": -2.0,      // Eating is slightly interesting
            "Fear": -4.0        // Food provides some comfort
        ],
        .walking: [
            "Happy": +8.0,      // Exercise creates good endorphins
            "Sad": -8.0,        // Exercise helps with sadness
            "Angry": -10.0,     // Physical activity releases anger
            "Bored": -20.0,     // Walking is the best cure for boredom
            "Fear": -3.0        // New environments might not help fear much
        ],
        .showering: [
            "Happy": +3.0,      // Clean feels good but not exciting
            "Sad": -2.0,        // Hygiene helps mood slightly
            "Angry": -6.0,      // Cleaning up can be calming
            "Bored": +4.0,      // Showering might be boring routine
            "Fear": -8.0        // Being clean reduces some fears
        ]
    ]
}
