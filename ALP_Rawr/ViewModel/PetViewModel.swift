//
//  PetViewModel.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import Foundation

class PetViewModel: ObservableObject {
    
    @Published var pet: PetModel = PetModel()
    
    init(){
        
    }
}
