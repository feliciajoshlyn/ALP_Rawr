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
    @Published var hasFetchData: Bool = false
    
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
        print("fetchPetData called")
        guard !hasFetchData else {
            print("Already fetched data, returning early")
            return
        }
        hasFetchData = true
        
        self.user = Auth.auth().currentUser
        guard let userId = user?.uid else {
            print("No user ID found, setting up default pet")
            setupDefaultPet()
            startTimer()  // Make sure timer is started here too
            return
        }
        
        print("Fetching pet for userId: \(userId)")
        petService.fetchPet(for: userId) { [weak self] pet in
            print("petService.fetchPet completion called")
            DispatchQueue.main.async{
                if let fetchedPet = pet {
                    print("Fetched pet successfully")
                    self?.pet = fetchedPet
                } else {
                    print("Failed to fetch pet, setting up default pet")
                    self?.setupDefaultPet()
                }
            }
        }
        self.startTimer()
    }

    
    private func setupDefaultPet(){
        self.pet = PetModel(
            name: "Default",
            hp: 100.0,
            hunger: 100.0,
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
                    level: 100.0,
                    limit: 40.0,
                    priority: 1,
                    icon: "happybadge"
                ),
                "Sad":PetEmotionModel(name: "Sad", level: 0.0, limit: 50.0, priority: 2, icon: "sadbadge"),
                "Angry":PetEmotionModel(name: "Angry", level: 0.0, limit: 70.0, priority: 3, icon: "angrybadge"),
                "Bored":PetEmotionModel(name: "Bored", level: 0.0, limit: 60.0, priority: 4, icon: "boredbadge"),
                "Fear":PetEmotionModel(name: "Fear", level: 0.0, limit: 80.0, priority: 5, icon: "fearbadge")
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
    
    func roundToDecimal(_ value: Double, places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (value * factor).rounded() / factor
    }
    
    func updatePetStatusPeriodically() {
        let now = Date()
        let lastChecked = pet.lastChecked
        let timePassed = now.timeIntervalSince(lastChecked) // in seconds
        
        guard timePassed >= 60 else { return } // Only update if at least 1 minute has passed
        
        let minutesPassed: Double = roundToDecimal(timePassed / 60.0, places: 1)
        
        // Adjust Hunger (decreases slowly - every 3 minutes decreases by 1)
        let hungerDecrease: Double = roundToDecimal(minutesPassed / 3.0, places: 1)
        pet.hunger = max(0.0, pet.hunger - hungerDecrease)
        pet.isHungry = pet.hunger < 40.0

        // Calculate hours since activities
        let hoursSinceFed = now.timeIntervalSince(pet.lastFed) / 3600
        let hoursSincePetted = now.timeIntervalSince(pet.lastPetted) / 3600
        let hoursSinceWalked = now.timeIntervalSince(pet.lastWalked) / 3600
        let hoursSinceShowered = now.timeIntervalSince(pet.lastShower) / 3600

        // Adjust HP with more balanced rates
        if pet.hunger >= 50.0 {
            // Regenerate HP when well-fed (slower regeneration)
            let hpIncrease: Double = roundToDecimal(minutesPassed / 5.0, places: 1) // Gain 1 HP every 5 minutes when well-fed
            pet.hp = min(100.0, pet.hp + hpIncrease)
        } else {
            // Apply decay with more gradual rates
            if pet.hunger < 15.0 { // Only severe hunger affects HP
                let hpDecrease = roundToDecimal(minutesPassed / 8, places: 3)  // Lose 1 HP every 8 minutes when starving
                pet.hp = max(1.0, pet.hp - hpDecrease)
            }
            
            // Neglect penalties (much more gradual)
            var neglectPenalty: Double = 0.0
            if hoursSinceFed > 8.0 { neglectPenalty += 1.0 }
            if hoursSincePetted > 12.0 { neglectPenalty += 1.0 }
            if hoursSinceWalked > 16.0 { neglectPenalty += 1.0 }
            if hoursSinceShowered > 30.0 { neglectPenalty += 1.0 }
            
            if neglectPenalty > 0.0 {
                let hpDecrease: Double = roundToDecimal((minutesPassed * neglectPenalty) / 15, places: 2) // Gradual penalty based on neglect
                pet.hp = max(1.0, pet.hp - hpDecrease)
                
            }
        }

        // Update emotion levels with more balanced and realistic rates
        for (name, emotion) in pet.emotions {
            var updated = emotion
            
            switch name {
            case "Sad":
                if hoursSincePetted > 6.0 {
                    // Gradual increase in sadness when not petted
                    let increase = min(3.0, roundToDecimal(minutesPassed / 10.0, places: 2)) // Max 3 points per update
                    updated.level = min(100.0, updated.level + increase)
                } else {
                    // Slowly decrease sadness when recently petted
                    let decrease: Double = roundToDecimal(minutesPassed / 15.0, places: 2)
                    updated.level = max(0.0, updated.level - decrease)
                }
                
            case "Angry":
                if pet.hunger < 30.0 {
                    // Get angry when hungry
                    let increase: Double = min(2.0, roundToDecimal(minutesPassed / 8.0, places: 3))
                    updated.level = min(100.0, updated.level + increase)
                } else if pet.hunger > 60.0 {
                    // Calm down when well-fed
                    let decrease: Double = roundToDecimal(minutesPassed / 12.0, places: 3)
                    updated.level = max(0.0, updated.level - decrease)
                }
                
            case "Bored":
                if hoursSinceWalked > 8.0 {
                    // Get bored without walks
                    let increase: Double = min(4.0, roundToDecimal(minutesPassed / 6.0, places: 3)) // Boredom builds faster
                    updated.level = min(100.0, updated.level + increase)
                } else {
                    // Less bored after walks
                    let decrease: Double = roundToDecimal(minutesPassed / 10.0, places: 3)
                    updated.level = max(0.0, updated.level - decrease)
                }
                
            case "Fear":
                if hoursSinceShowered > 48.0 { // Only after being very dirty
                    // Slight fear from being too dirty
                    let increase: Double = min(1.0, roundToDecimal(minutesPassed / 20.0, places: 3))
                    updated.level = min(100.0, updated.level + increase)
                } else {
                    // Fear naturally decreases over time
                    let decrease: Double = roundToDecimal(minutesPassed / 25.0, places: 3)
                    updated.level = max(0, updated.level - decrease)
                }
                
            case "Happy":
                // Happiness depends on overall care
                let overallCare = (pet.hunger + pet.hp) / 2
                
                if overallCare > 70 {
                    // Increase happiness when well cared for
                    let increase: Double = roundToDecimal(minutesPassed / 8.0, places: 3)
                    updated.level = min(100.0, updated.level + increase)
                } else if overallCare < 40.0 {
                    // Decrease happiness when neglected
                    let decrease: Double = roundToDecimal(minutesPassed / 6.0, places: 3)
                    updated.level = max(0.0, updated.level - decrease)
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
    
//    func updatePetStatusPeriodicallyFaster() {
//        let now = Date()
//        let lastChecked = pet.lastChecked
//        let timePassed = now.timeIntervalSince(lastChecked) // in seconds
//        
//        guard timePassed >= 60 else { return } // Only update if at least 1 minute has passed
//        
//        let minutesPassed = Double(timePassed / 60.0)
//        
//        // Adjust Hunger (every minute decreases by 1)
//        pet.hunger = max(0, pet.hunger - minutesPassed)
//        pet.isHungry = pet.hunger < 40
//
//        // Adjust HP based on lack of interaction
//        let hoursSinceFed = Double(now.timeIntervalSince(pet.lastFed) / 3600.0)
//        let hoursSincePetted = Double(now.timeIntervalSince(pet.lastPetted) / 3600.0)
//        let hoursSinceWalked = Double(now.timeIntervalSince(pet.lastWalked) / 3600.0)
//        let hoursSinceShowered = Double(now.timeIntervalSince(pet.lastShower) / 3600.0)
//
//        // HP decays slightly if hunger is very low or if neglected
//        if pet.hunger < 20.0 {
//            pet.hp = max(0.0, pet.hp - minutesPassed / 2.0)
//        }
//        if hoursSinceFed > 6.0 || hoursSincePetted > 8.0 || hoursSinceWalked > 12.0 || hoursSinceShowered > 24.0 {
//            pet.hp = max(0, pet.hp - minutesPassed / 3.0)
//        }
//
//        // Increase emotion levels based on neglect
//        for (name, emotion) in pet.emotions {
//            var updated = emotion
//            switch name {
//            case "Sad":
//                updated.level = min(100, updated.level + (hoursSincePetted > 8 ? minutesPassed / 3 : 0))
//            case "Angry":
//                updated.level = min(100, updated.level + (hoursSinceFed > 6 ? minutesPassed / 4 : 0))
//            case "Bored":
//                updated.level = min(100, updated.level + (hoursSinceWalked > 12 ? minutesPassed / 2 : 0))
//            case "Fear":
//                updated.level = min(100, updated.level + (hoursSinceShowered > 24 ? minutesPassed / 2 : 0))
//            case "Happy":
//                updated.level = max(0, updated.level - minutesPassed / 2)
//            default:
//                break
//            }
//            pet.emotions[name] = updated
//        }
//
//        pet.lastChecked = now
//        checkCurrEmotion()
//    }
    
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
        timer?.invalidate()
    }
}
