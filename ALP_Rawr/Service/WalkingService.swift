//
//  WalkingService.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 30/05/25.
//

import Foundation
import FirebaseDatabase

class WalkingService {
    private var dbRef = Database.database().reference().child("walkings") // buat /walkings
    private var petRef = Database.database().reference().child("pets") // /pets -> karena mau nyimpen kedalam pet juga
    
    func createWalkTracker(walk: WalkingModel, for userId: String, completion: @escaping (Bool) -> Void) {
        let userWalkRef = dbRef.child(userId).childByAutoId() // generate id baru pake userId per walking. /walkings/{userId}/{uuid walking}
        
        do {
            let jsonData = try JSONEncoder().encode(walk) // ubah ke format json untuk walk nya
            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] { // json diubah kedalam [String: Any] -> format yang di expect sama firebase
                userWalkRef.setValue(json) { error, _ in
                    completion(error == nil) // return completion true kalo berhasil
                }
            } else {
                print("Failed to serialize JSON")
                completion(false)
            }
        } catch {
            print("Encoding error: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    
    
}
