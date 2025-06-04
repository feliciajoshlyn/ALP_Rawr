//
//  MockAuthService.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 04/06/25.
//

import Foundation

class MockAuthService: AuthServiceProtocol {
    var signUpCalled = false
    var signInCalled = false
    var signOutCalled = false
    var shouldReturnSuccess: Bool = true
    
    private var mockUsers: [MyUser] = []
    private var currentUser: MyUser?
    
    func signUp(email: String, password: String, username: String, petName: String) async throws -> MyUser {
        signUpCalled = true
        
        if shouldReturnSuccess {
            let newUser = MyUser(
                uid: UUID().uuidString,
                username: username,
                email: email,
                password: "", // Don't store password for security
                friends: []
            )
            mockUsers.append(newUser)
            currentUser = newUser
            
            return newUser
        } else {
            throw NSError(domain: "MockAuth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock sign-up failed"])
        }
    }

    func signIn(email: String, password: String, username: String) async throws -> MyUser {
        signInCalled = true
        
        if shouldReturnSuccess {
            if let existingUser = mockUsers.first(where: { $0.email == email }) {
                currentUser = existingUser
                return currentUser!
            } else {
                // Create a mock user for testing if not found
                let mockUser = MyUser(
                    uid: UUID().uuidString,
                    username: username,
                    email: email,
                    password: "",
                    friends: []
                )
                currentUser = mockUser
                return mockUser
            }
        } else {
            throw NSError(domain: "MockAuth", code: 2, userInfo: [NSLocalizedDescriptionKey: "Mock sign-in failed"])
        }
    }
    
    // Helper methods for testing
    func getCurrentUser() -> MyUser? {
        return currentUser
    }
    
    func addMockUser(email: String, password: String, username: String) {
        let user = MyUser(
            uid: UUID().uuidString,
            username: username,
            email: email,
            password: "",
            friends: []
        )
        mockUsers.append(user)
    }
    
    func clearMockUsers() {
        mockUsers.removeAll()
        currentUser = nil
    }
}
