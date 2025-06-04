//
//  AuthService.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 04/06/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService: AuthServiceProtocol {
    private let db = Firestore.firestore()
    private let userService: UserServiceProtocol
    private let petService: PetService
    
    init(userService: UserServiceProtocol = UserService(), petService: PetService = LivePetService()) {
        self.userService = userService
        self.petService = petService
    }
    
    func signIn(email: String, password: String, username: String) async throws -> MyUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = result.user
        
        // Return MyUser instead of Firebase User
        return MyUser(
            uid: user.uid,
            username: user.displayName ?? username,
            email: user.email ?? email,
            password: "", // Don't store password for security
            friends: []
        )
    }
    
    func signUp(email: String, password: String, username: String, petName: String) async throws -> MyUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = result.user
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = username
        try await changeRequest.commitChanges()
        print("✅ Updated displayName to \(username)")
        
        print("User created successfully with UID: \(user.uid)")

        try await userService.createUserDocument(
            userId: user.uid,
            email: email,
            username: username
        )
        print("Firestore user document created")
        
        // Create default pet
        let defaultPet = makeDefaultPet(userId: user.uid, petName: petName)
        print("Creating default pet: \(defaultPet.name) for user: \(user.uid)")
        
        let petCreated = await createPetAsync(pet: defaultPet)
        
        if !petCreated {
            print("Failed to create default pet in Firebase")
            throw NSError(domain: "AuthService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to create default pet"])
        }
        
        print("Default pet created successfully in Firebase")
        
        return MyUser(
            uid: user.uid,
            username: username,
            email: email,
            password: "", // Don't store password for security
            friends: []
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func createPetAsync(pet: PetModel) async -> Bool {
        return await withCheckedContinuation { continuation in
            petService.createPet(pet: pet) { success in
                continuation.resume(returning: success)
            }
        }
    }
    
    private func makeDefaultPet(userId: String, petName: String) -> PetModel {
        let now = Date()
        
        return PetModel(
            name: petName,
            hp: 100.0,
            hunger: 100.0,
            isHungry: false,
            bond: 0.0,
            lastFed: now,
            lastPetted: now,
            lastWalked: now,
            lastShower: now,
            lastChecked: now,
            currMood: "Happy",
            emotions: [
                "Happy": PetEmotionModel(
                    name: "Happy",
                    level: 100.0,
                    limit: 40.0,
                    priority: 1,
                    icon: "happybadge"
                ),
                "Sad": PetEmotionModel(name: "Sad", level: 0.0, limit: 50.0, priority: 2, icon: "sadbadge"),
                "Angry": PetEmotionModel(name: "Angry", level: 0.0, limit: 70.0, priority: 3, icon: "angrybadge"),
                "Bored": PetEmotionModel(name: "Bored", level: 0.0, limit: 60.0, priority: 4, icon: "boredbadge"),
                "Fear": PetEmotionModel(name: "Fear", level: 0.0, limit: 80.0, priority: 5, icon: "fearbadge")
            ],
            userId: userId
        )
    }
}
