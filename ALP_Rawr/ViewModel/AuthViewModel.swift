//
//  AuthViewModel.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isSigningIn: Bool
    @Published var myUser: MyUser
    @Published var falseCredential: Bool
    @Published var petName: String = ""
    
    private var ref: DatabaseReference
    
    private let petService: PetService
    private let userService: UserService
    private let db = Firestore.firestore()
    
    init(petService: PetService = PetService(), userService: UserService = UserService()){
        self.user = nil
        self.isSigningIn = false
        self.falseCredential = false
        self.myUser = MyUser()
        
        self.ref = Database.database().reference().child("pets")
        self.petService = petService
        self.userService = userService
        
        self.checkUserSession()
        
    }
    
    func checkUserSession(){
        //check jika pernah login, kl login akan return user
        self.user = Auth.auth().currentUser
        self.myUser.uid = Auth.auth().currentUser?.uid ?? ""
        self.myUser.email = Auth.auth().currentUser?.email ?? ""
        self.myUser.username = Auth.auth().currentUser?.displayName ?? ""
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
        do {
            let result = try await Auth.auth().signIn(withEmail: myUser.email, password: myUser.password)
            let user = result.user

            //access firestore
            let db = Firestore.firestore()
            //get firestore sesuai dengan nama uid like users/uid spt id
            let userRef = db.collection("users").document(user.uid)
            //wait so they get the document
            let snapshot = try await userRef.getDocument()
            
            //if missing
            if !snapshot.exists {
                //set data utk user uid tersebut
                try await userRef.setData([
                    "email": user.email ?? "",
                    "username": myUser.username,
                    "friends": []
                ])
            }

            DispatchQueue.main.async {
                self.falseCredential = false
                self.user = user
                self.myUser.uid = user.uid
                self.myUser.email = user.email ?? ""
                self.myUser.username = user.displayName ?? ""
            }
        } catch {
            DispatchQueue.main.async {
                self.falseCredential = true
            }
        }
    }
    
    func signUp() async {
        do {
            let result = try await Auth.auth().createUser(withEmail: myUser.email, password: myUser.password)
            let user = result.user
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = myUser.username
            try await changeRequest.commitChanges()
            print("✅ Updated displayName to \(myUser.username)")
            
            self.myUser.uid = user.uid
            print("User created successfully with UID: \(user.uid)")
            
//             Create Firestore user document
//            let db = Firestore.firestore()
//            let userRef = db.collection("users").document(user.uid)
//            try await userRef.setData([
//                "email": user.email ?? "",
//                "username": myUser.username,
//                "friends": []
//            ])
            
            try await userService.createUserDocument(
                userId: user.uid,
                email: myUser.email,
                username: myUser.username
            )
            print("Firestore user document created")
            
            // Create default pet - AWAIT the async operation
            let defaultPet = makeDefaultPet(userId: user.uid, petName: self.petName) // Fixed: use myUser.petName
            print("Creating default pet: \(defaultPet.name) for user: \(user.uid)")
            
            // Use async/await instead of completion handler for better error handling
            let petCreated = await createPetAsync(pet: defaultPet)
            
            await MainActor.run {
                if petCreated {
                    print("Default pet created successfully in Firebase")
                    self.falseCredential = false
                    self.user = user
                } else {
                    print("Failed to create default pet in Firebase")
                    self.falseCredential = true
                }
            }
            
        } catch {
            print("SignUp error: \(error.localizedDescription)")
            await MainActor.run {
                self.falseCredential = true
            }
        }
    }
    

    // MARK: - Async Pet Creation Helper
    func createPetAsync(pet: PetModel) async -> Bool {
        return await withCheckedContinuation { continuation in
            petService.createPet(pet: pet) { success in
                continuation.resume(returning: success)
            }
        }
    }
    
    func makeDefaultPet(userId: String, petName: String) -> PetModel {
        let now = Date()
        
        return PetModel(
            name: petName,
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
            userId: userId
        )
    }
}
