//
//  MockUserService.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 04/06/25.
//

import Foundation

class MockUserService: UserServiceProtocol {
    var mockUser: MyUser?
    var createUserDocumentCalled: Bool = false
    var signOutCalled: Bool = false
    
    func createUserDocument(userId: String, email: String, username: String) async throws {
        createUserDocumentCalled = true
        mockUser = MyUser(
            uid: userId,
            username: username,
            email: email,
            password: "",
            friends: []
        )
    }
    
    func signOut() throws {
        signOutCalled = true
    }
}
