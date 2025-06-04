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
        let userWalkRef = dbRef.child(userId).childByAutoId() // generate id baru buat walking
        
        do {
            let jsonData = try JSONEncoder().encode(walk)
            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                userWalkRef.setValue(json) { error, _ in
                    completion(error == nil)
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
