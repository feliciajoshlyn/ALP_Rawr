//
//  PetServiceInterface.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 01/06/25.
//

import Foundation

protocol PetService {
    func fetchPet(for userId: String, completion: @escaping (PetModel?) -> Void)
    func createPet(pet: PetModel, completion: @escaping (Bool) -> Void)
    func savePet(_ pet: PetModel, for userId: String, completion: @escaping (Bool) -> Void)
}
