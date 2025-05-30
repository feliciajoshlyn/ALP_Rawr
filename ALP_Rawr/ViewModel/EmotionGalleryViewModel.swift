//
//  EmotionGalleryViewModel.swift
//  ALP_Rawr
//
//  Created by student on 30/05/25.
//

import Foundation

class EmotionGalleryViewModel: ObservableObject {
    
    @Published var emotions: [EmotionModel] = [
        EmotionModel(
            name: "Happy",
            description: "Happy is when you feel really good, like when you play with your friends or get a hug.",
            copingStrategies: [
                "Smile and enjoy the moment",
                "Share your joy with others",
                "Say thank you to someone who helped you"
            ],
            color: .orange,
            cardImage: "happycard"
        ),
        EmotionModel(
            name: "Sad",
            description: "Sad is when your heart feels heavy, like when you lose your toy or someone says something mean.",
            copingStrategies: [
                "Talk to someone you trust",
                "Cry if you need to — it’s okay",
                "Do something that makes you feel better, like drawing or cuddling a toy"
            ],
            color: .indigo,
            cardImage: "sadcard"
        ),
        EmotionModel(
            name: "Angry",
            description: "Angry is when you feel like shouting or your body feels tight because something upset you.",
            copingStrategies: [
                "Take deep breaths slowly",
                "Count to 10 before you speak",
                "Walk away and take a break"
            ],
            color: .red,
            cardImage: "angrycard"
        ),
        EmotionModel(
            name: "Bored",
            description: "Bored is when you feel like there's nothing fun to do or everything feels slow.",
            copingStrategies: [
                "Try a new activity or game",
                "Use your imagination — make up a story or pretend play",
                "Help someone with a task"
            ],
            color: .secondary,
            cardImage: "boredcard"
        ),
        EmotionModel(
            name: "Fear",
            description: "Fear is when you feel scared, like when it's dark or you hear a loud noise.",
            copingStrategies: [
                "Hold someone's hand or talk to a trusted adult",
                "Take deep breaths and close your eyes for a moment",
                "Use a nightlight or comforting object like a stuffed animal"
            ],
            color: .mint,
            cardImage: "fearcard"
        )
    ]
    
    
    
    
}
