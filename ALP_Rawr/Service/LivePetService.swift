//
//  PetService.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 28/05/25.
//

import Foundation
import FirebaseDatabase

class LivePetService: PetService{
    private let ref = Database.database().reference().child("pets")
    
    func fetchPet(for userId: String, completion: @escaping (PetModel?) -> Void){
        ref.child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let petDict = snapshot.value as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: petDict),
                  let pet = try? JSONDecoder().decode(PetModel.self, from: jsonData)
            else {
                print("Failed to decode pet data.")
                completion(nil)
                return
            }
            
            completion(pet)
        }
    }
    
    func createPet(pet: PetModel, completion: @escaping (Bool) -> Void){
        guard let jsonData = try? JSONEncoder().encode(pet),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else {
            print("Failed to create Pet")
            completion(false)
            return
        }
        
        ref.child(pet.userId).setValue(json)
        completion(true)
    }
    
    func savePet(_ pet: PetModel, for userId: String, completion: @escaping (Bool) -> Void) {
        let saveRef = self.ref.child(userId)
        
        do {
            let data = try JSONEncoder().encode(pet)
            if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                saveRef.setValue(dict) { error, _ in
                    completion(error == nil)
                }
            } else {
                completion(false)
            }
        } catch {
            completion(false)
        }
    }
}
