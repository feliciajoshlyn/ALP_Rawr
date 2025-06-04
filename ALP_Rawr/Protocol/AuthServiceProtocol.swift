//
//  AuthServiceProtocol.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 04/06/25.
//

import Foundation

protocol AuthServiceProtocol {
    func signUp(email: String, password: String, username: String, petName: String) async throws -> MyUser
    func signIn(email: String, password: String, username: String) async throws -> MyUser
}
