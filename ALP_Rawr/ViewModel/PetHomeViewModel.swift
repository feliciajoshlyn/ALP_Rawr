//
//  PetViewModel.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class PetHomeViewModel: ObservableObject {
    
    @Published var pet: PetModel = PetModel()
    @Published var currEmotion: String = "Happy"
    @Published var icon: String = "happybadge"
    
    private var ref: DatabaseReference
    private var user: User?
    private(set) var hasFetchData: Bool = false
    
    init() {
        self.ref = Database.database().reference().child("pets")
    }
    
    func fetchPetData() {
        guard !hasFetchData else { return }
        hasFetchData = true
        
        self.user = Auth.auth().currentUser
        if let userId = user?.uid {
            ref.child(userId).observeSingleEvent(of: .value) { snapshot in
                guard let petDict = snapshot.value as? [String: Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: petDict),
                      let pet = try? JSONDecoder().decode(PetModel.self, from: jsonData)
                else {
                    print("Failed to decode pet data.")
                    self.pet = PetModel()
                    return
                }
                
                DispatchQueue.main.async {
                    self.pet = pet
                }
            }
        } else {
            self.pet = PetModel(
                name: "Default",
                hp: 100,
                hunger: 100,
                isHungry: false,
                bond: 0,
                lastFed: Date(),
                lastPetted: Date(),
                lastWalked: Date(),
                currMood: "Happy",
                emotions: [
                    "Happy":EmotionModel(
                        name: "Happy",
                        level: 100,
                        limit: 40,
                        priority: 1,
                        icon: "happybadge"
                    ),
                    "Sad":EmotionModel(name: "Sad", level: 0, limit: 50, priority: 2, icon: "sadbadge"),
                    "Angry":EmotionModel(name: "Angry", level: 0, limit: 70, priority: 3, icon: "angrybadge"),
                    "Bored":EmotionModel(name: "Bored", level: 0, limit: 60, priority: 4, icon: "boredbadge"),
                    "Fear":EmotionModel(name: "Fear", level: 0, limit: 80, priority: 5, icon: "fearbadge")
                ],
                userId: ""
            )
        }
    }
    
    func applyInteraction(_ type: InteractionType) {
        guard let changes = InteractionEffect.effects[type] else { return }

        for (emotionName, num) in changes {
            if var emotion = pet.emotions[emotionName] {
                emotion.apply(change: num)
                pet.emotions[emotionName] = emotion
            }
        }
        
        if type == .petting {
            pet.lastPetted = Date()
        }
        
        self.checkCurrEmotion()
    }
    
    func checkCurrEmotion(){
        let activeEmotions = pet.emotions.filter { $0.value.level >= $0.value.limit }
        
        if activeEmotions.isEmpty {
            self.currEmotion = "Happy"
            self.icon = "happybadge"
            return
        }
        
        let sortedEmotions = activeEmotions.sorted {
            return $0.value.priority > $1.value.priority
        }
        
        if let topEmotion = sortedEmotions.first {
            self.currEmotion = topEmotion.key
            self.icon = topEmotion.value.icon
        } else {
            self.currEmotion = "Happy"
            self.icon = "happybadge"
        }
    }
}
