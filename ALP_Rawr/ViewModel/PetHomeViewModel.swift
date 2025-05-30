//
//  PetViewModel.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import WatchConnectivity

class PetHomeViewModel: NSObject, ObservableObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
    @Published var pet: PetModel = PetModel()
    @Published var currEmotion: String = "Happy"
    @Published var icon: String = "happybadge"
    
    private let petService: PetService

    private var user: User?
    private(set) var hasFetchData: Bool = false
    
    private var timer: Timer?
    
    var session: WCSession
    init(petService: PetService = PetService(), session: WCSession = .default) {
        self.petService = petService
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
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
                "Happy":PetEmotionModel(
                    name: "Happy",
                    level: 100,
                    limit: 40,
                    priority: 1,
                    icon: "happybadge"
                ),
                "Sad":PetEmotionModel(name: "Sad", level: 0, limit: 50, priority: 2, icon: "sadbadge"),
                "Angry":PetEmotionModel(name: "Angry", level: 0, limit: 70, priority: 3, icon: "angrybadge"),
                "Bored":PetEmotionModel(name: "Bored", level: 0, limit: 60, priority: 4, icon: "boredbadge"),
                "Fear":PetEmotionModel(name: "Fear", level: 0, limit: 80, priority: 5, icon: "fearbadge")
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
        
        // Adjust Hunger (decreases slowly - every 3 minutes decreases by 1)
        let hungerDecrease = minutesPassed / 3
        pet.hunger = max(0, pet.hunger - hungerDecrease)
        pet.isHungry = pet.hunger < 40

        // Calculate hours since activities
        let hoursSinceFed = Int(now.timeIntervalSince(pet.lastFed) / 3600)
        let hoursSincePetted = Int(now.timeIntervalSince(pet.lastPetted) / 3600)
        let hoursSinceWalked = Int(now.timeIntervalSince(pet.lastWalked) / 3600)
        let hoursSinceShowered = Int(now.timeIntervalSince(pet.lastShower) / 3600)

        // Adjust HP with more balanced rates
        if pet.hunger >= 50 {
            // Regenerate HP when well-fed (slower regeneration)
            let hpIncrease = minutesPassed / 5 // Gain 1 HP every 5 minutes when well-fed
            pet.hp = min(100, pet.hp + hpIncrease)
        } else {
            // Apply decay with more gradual rates
            if pet.hunger < 15 { // Only severe hunger affects HP
                let hpDecrease = minutesPassed / 8 // Lose 1 HP every 8 minutes when starving
                pet.hp = max(1, pet.hp - hpDecrease)
            }
            
            // Neglect penalties (much more gradual)
            var neglectPenalty = 0
            if hoursSinceFed > 8 { neglectPenalty += 1 }
            if hoursSincePetted > 12 { neglectPenalty += 1 }
            if hoursSinceWalked > 16 { neglectPenalty += 1 }
            if hoursSinceShowered > 30 { neglectPenalty += 1 }
            
            if neglectPenalty > 0 {
                let hpDecrease = (minutesPassed * neglectPenalty) / 15 // Gradual penalty based on neglect
                pet.hp = max(1, pet.hp - hpDecrease)
            }
        }

        // Update emotion levels with more balanced and realistic rates
        for (name, emotion) in pet.emotions {
            var updated = emotion
            
            switch name {
            case "Sad":
                if hoursSincePetted > 6 {
                    // Gradual increase in sadness when not petted
                    let increase = min(3, minutesPassed / 10) // Max 3 points per update
                    updated.level = min(100, updated.level + increase)
                } else {
                    // Slowly decrease sadness when recently petted
                    let decrease = minutesPassed / 15
                    updated.level = max(0, updated.level - decrease)
                }
                
            case "Angry":
                if pet.hunger < 30 {
                    // Get angry when hungry
                    let increase = min(2, minutesPassed / 8)
                    updated.level = min(100, updated.level + increase)
                } else if pet.hunger > 60 {
                    // Calm down when well-fed
                    let decrease = minutesPassed / 12
                    updated.level = max(0, updated.level - decrease)
                }
                
            case "Bored":
                if hoursSinceWalked > 8 {
                    // Get bored without walks
                    let increase = min(4, minutesPassed / 6) // Boredom builds faster
                    updated.level = min(100, updated.level + increase)
                } else {
                    // Less bored after walks
                    let decrease = minutesPassed / 10
                    updated.level = max(0, updated.level - decrease)
                }
                
            case "Fear":
                if hoursSinceShowered > 48 { // Only after being very dirty
                    // Slight fear from being too dirty
                    let increase = min(1, minutesPassed / 20)
                    updated.level = min(100, updated.level + increase)
                } else {
                    // Fear naturally decreases over time
                    let decrease = minutesPassed / 25
                    updated.level = max(0, updated.level - decrease)
                }
                
            case "Happy":
                // Happiness depends on overall care
                let overallCare = (pet.hunger + pet.hp) / 2
                
                if overallCare > 70 {
                    // Increase happiness when well cared for
                    let increase = minutesPassed / 8
                    updated.level = min(100, updated.level + increase)
                } else if overallCare < 40 {
                    // Decrease happiness when neglected
                    let decrease = minutesPassed / 6
                    updated.level = max(0, updated.level - decrease)
                }
                // Maintain current level if care is moderate (40-70)
                
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
    
    func resetViewModel(){
        currEmotion = "Happy"
        icon = "happybadge"
        hasFetchData = false
    }
}
