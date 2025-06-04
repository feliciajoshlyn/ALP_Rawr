//
//  MockPetService.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 01/06/25.
//

import Foundation

class MockPetService: PetServiceProtocol {
    var fetchPetCalled = false
    var createPetCalled = false
    var savePetCalled = false

    var mockPetToReturn: PetModel? = PetModel(
        name: "MockPet",
        hp: 100.0,
        hunger: 100.0,
        isHungry: false,
        bond: 0.0,
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
        userId: "000"
    )
    
    var mockPetSave: PetModel?
    var shouldSaveSucceed: Bool = true
    var shouldCreateSucceed: Bool = true

    func fetchPet(for userId: String, completion: @escaping (PetModel?) -> Void) {
        fetchPetCalled = true
        completion(mockPetToReturn)
    }

    func createPet(pet: PetModel, completion: @escaping (Bool) -> Void) {
        createPetCalled = true
        completion(shouldCreateSucceed)
    }

    func savePet(_ pet: PetModel, for userId: String, completion: @escaping (Bool) -> Void) {
        savePetCalled = true
        mockPetSave = pet
        completion(shouldSaveSucceed)
    }
}
