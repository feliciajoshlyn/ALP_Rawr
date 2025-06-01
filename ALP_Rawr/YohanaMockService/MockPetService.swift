//
//  MockPetService.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 01/06/25.
//

import Foundation

class MockPetService: PetService {
    var fetchPetCalled = false
    var createPetCalled = false
    var savePetCalled = false

    var mockPetToReturn: PetModel? = nil
    var shouldSaveSucceed: Bool = true
    var shouldCreateSucceed: Bool = true

    func fetchPet(for userId: String, completion: @escaping (PetModel?) -> Void) {
        fetchPetCalled = true
        completion(mockPetToReturn)
    }

    func createPet(pet: PetModel, completion: @escaping (Bool) -> Void) {
        createPetCalled = true
        completion(shouldCreateSucceed)
    }

    func savePet(_ pet: PetModel, for userId: String, completion: @escaping (Bool) -> Void) {
        savePetCalled = true
        completion(shouldSaveSucceed)
    }
}
