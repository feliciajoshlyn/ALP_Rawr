//
//  UserService.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 29/05/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserService: UserServiceProtocol {
    private let fbFirestore = Firestore.firestore()
    
    func createUserDocument(userId: String, email: String, username: String) async throws {
        let userRef = fbFirestore.collection("users").document(userId)
        try await userRef.setData([
            "email": email,
            "username": username,
            "friends": []
        ])
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
