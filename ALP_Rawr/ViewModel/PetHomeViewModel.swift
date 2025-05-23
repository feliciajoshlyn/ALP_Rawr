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
    private var user: User? = Auth.auth().currentUser
    
    init() async {
        self.ref = Database.database().reference().child("pets")
        await self.fetchPetData(userId: user!.uid)
    }
    
    func fetchPetData(userId: String) async {
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
    }
    
    func petting(){
        for _ in 0..<pet.emotions.count {
            if var happy = pet.emotions["Happy"] {
                happy.level = min(happy.level + 10, 100)
                pet.emotions["Happy"] = happy
            } else if var sad = pet.emotions["Sad"] {
                sad.level = max(sad.level - 8, 0)
                pet.emotions["Sad"] = sad
            } else if var angry = pet.emotions["Angry"] {
                angry.level = max(angry.level - 6, 0)
                pet.emotions["Angry"] = angry
            } else if var bored = pet.emotions["Bored"] {
                bored.level = max(bored.level - 4, 0)
                pet.emotions["Bored"] = bored
            } else if var fear = pet.emotions["Fear"] {
                fear.level = max(fear.level - 10, 0)
                pet.emotions["Fear"] = fear
            }
        }
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
