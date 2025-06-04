//
//  UserServiceProtocol.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 04/06/25.
//

import Foundation

protocol UserServiceProtocol {
    func createUserDocument(userId: String, email: String, username: String) async throws
    func signOut() throws
}
