//
//  AuthViewModel.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isSigningIn: Bool
    @Published var myUser: MyUser
    @Published var falseCredential: Bool
    
    private var ref: DatabaseReference
    
    init(){
        self.user = nil
        self.isSigningIn = false
        self.falseCredential = false
        self.myUser = MyUser()
        
        self.ref = Database.database().reference().child("pets")
        
        self.checkUserSession()
    }
    
    func checkUserSession(){
        //check jika pernah login, kl login akan return user
        self.user = Auth.auth().currentUser
        self.isSigningIn = self.user != nil
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func signIn() async {
        do{
            _ = try await Auth.auth().signIn(withEmail: myUser.email, password: myUser.password)
            
            DispatchQueue.main.async {
                self.falseCredential = false
            }
        } catch {
            DispatchQueue.main.async {
                self.falseCredential = true
            }
            
        }
    }
    
    func signUp() async {
        do{
            let result = try await Auth.auth().createUser(withEmail: myUser.email, password: myUser.password)
            let userId = result.user.uid
            
            DispatchQueue.main.async {
                self.falseCredential = false
            }
            
            let defaultPet = makeDefaultPet(userId: userId)
            await self.savePetDB(pet: defaultPet)
            
        } catch {
            DispatchQueue.main.async {
                self.falseCredential = true
            }
            
        }
    }
    
    func savePetDB(pet: PetModel) async {
        guard let jsonData = try? JSONEncoder().encode(pet),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else {
            return
        }
        
        do {
            try await ref.child(pet.userId).setValue(json)
        } catch {
            print("Error initializing pet: \(error)")
        }
    }
    
    func makeDefaultPet(userId: String) -> PetModel {
        let now = Date()
        
        return PetModel(
            name: "",
            hp: 100,
            hunger: 100,
            isHungry: false,
            bond: 0,
            lastFed: now,
            lastPetted: now,
            lastWalked: now,
            lastShower: now,
            lastChecked: now,
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
            userId: userId
        )
    }
}
