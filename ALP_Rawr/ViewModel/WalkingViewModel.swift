//
//  WalkingViewModel.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 30/05/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class WalkingViewModel: ObservableObject{
    private let walkingService: WalkingService
    private var user: User?
    
    @Published var walk: WalkingModel = WalkingModel()
    
    
    init(walkingService: WalkingService = WalkingService()) {
        self.walkingService = walkingService
    }
    
    func createWalking(walk: WalkingModel){
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        walkingService.createWalkTracker(walk: walk, for: userId){ success in
            if success {
                print("Walk create succesfully")
            } else {
                print("Failed to create Walk")
            }
        }
    }
    
    
}
