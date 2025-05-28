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
    
    private let petService: PetService

    private var user: User?
    private(set) var hasFetchData: Bool = false
    
    private var timer: Timer?
    
    init(petService: PetService = PetService()) {
        self.petService = petService
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func fetchPetData() {
        guard !hasFetchData else { return }
        hasFetchData = true
        
        self.user = Auth.auth().currentUser
        guard let userId = user?.uid else {
            setupDefaultPet()
            return
        }
        
        petService.fetchPet(for: userId) { [weak self] pet in
            DispatchQueue.main.async{
                if let fetchedPet = pet {
                    self?.pet = fetchedPet
                } else {
                    self?.setupDefaultPet()
                }
                self?.startTimer()
            }
        }
    }
    
    private func setupDefaultPet(){
        self.pet = PetModel(
            name: "Default",
            hp: 100,
            hunger: 100,
            isHungry: false,
            bond: 0,
            lastFed: Date(),
            lastPetted: Date(),
            lastWalked: Date(),
            lastShower: Date(),
            lastChecked: Date(),
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
        } else if type == .feeding {
            pet.lastFed = Date()
            pet.hunger = min(100, pet.hunger + 1)
        } else if type == .showering {
            pet.lastShower = Date()
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
    
    func updatePetStatusPeriodically() {
        let now = Date()
        let lastChecked = pet.lastChecked
        let timePassed = now.timeIntervalSince(lastChecked) // in seconds
        
        guard timePassed >= 60 else { return } // Only update if at least 1 minute has passed
        
        let minutesPassed = Int(timePassed / 60)
        
        // Adjust Hunger (every minute decreases by 1)
        pet.hunger = max(0, pet.hunger - minutesPassed)
        pet.isHungry = pet.hunger < 40

        // Adjust HP based on lack of interaction
        let hoursSinceFed = Int(now.timeIntervalSince(pet.lastFed) / 3600)
        let hoursSincePetted = Int(now.timeIntervalSince(pet.lastPetted) / 3600)
        let hoursSinceWalked = Int(now.timeIntervalSince(pet.lastWalked) / 3600)
        let hoursSinceShowered = Int(now.timeIntervalSince(pet.lastShower) / 3600)

        if pet.hunger >= 80 {
            // Regenerate HP when well-fed
            pet.hp = min(100, pet.hp + minutesPassed / 2)
        } else {
            // Apply decay only when not well-fed
            if pet.hunger < 20 {
                pet.hp = max(0, pet.hp - minutesPassed / 2)
            }
            if hoursSinceFed > 6 || hoursSincePetted > 8 || hoursSinceWalked > 12 || hoursSinceShowered > 24 {
                pet.hp = max(0, pet.hp - minutesPassed / 3)
            }
        }

        // Increase emotion levels based on neglect
        for (name, emotion) in pet.emotions {
            var updated = emotion
            switch name {
            case "Sad":
                updated.level = min(100, updated.level + (hoursSincePetted > 8 ? minutesPassed / 3 : 0))
            case "Angry":
                updated.level = min(100, updated.level + (hoursSinceFed > 6 ? minutesPassed / 4 : 0))
            case "Bored":
                updated.level = min(100, updated.level + (hoursSinceWalked > 12 ? minutesPassed / 2 : 0))
            case "Fear":
                updated.level = min(100, updated.level + (hoursSinceShowered > 24 ? minutesPassed / 2 : 0))
            case "Happy":
                updated.level = max(0, updated.level - minutesPassed / 2)
            default:
                break
            }
            pet.emotions[name] = updated
        }

        pet.lastChecked = now
        checkCurrEmotion()
    }
    
    private func startTimer() {
        timer?.invalidate() // in case it's called twice
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updatePetStatusPeriodically()
            }
        }
    }
    
    func savePet(){
        guard let userId = user?.uid else {
            return
        }
        
        self.updatePetStatusPeriodically()
        self.checkCurrEmotion()
        
        petService.savePet(self.pet, for: userId) { success in
            if success {
                print("Pet saved successfully on app background")
            } else {
                print("Failed to save pet on app background")
            }
        }
    }
    
    func refetchPetData() {
        fetchPetData()
        self.updatePetStatusPeriodically()
        self.checkCurrEmotion()
    }
}
