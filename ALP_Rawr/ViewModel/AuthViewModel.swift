//
//  AuthViewModel.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    
    @Published var isSigningIn: Bool = false
    @Published var user: User? = Auth.auth().currentUser
    @Published var myUser: MyUser = MyUser()
    @Published var falseCredential: Bool = false
    @Published var petName: String = ""
    
    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService(), userService: UserServiceProtocol = UserService()) {
        self.authService = authService
        self.userService = userService
        
        checkUserSession()
    }
    
    func checkUserSession() {
        if let currentUser = Auth.auth().currentUser {
            DispatchQueue.main.async {
                self.user = currentUser
                self.myUser = MyUser(
                    uid: currentUser.uid,
                    username: currentUser.displayName ?? "",
                    email: currentUser.email ?? "",
                    password: "",
                    friends: []
                )
                self.isSigningIn = true
            }
        } else {
            DispatchQueue.main.async {
                self.user = nil
                self.myUser = MyUser()
                self.isSigningIn = false
            }
        }
    }

    func signOut() {
        do {
            try userService.signOut()
            DispatchQueue.main.async {
                self.user = nil
                self.myUser = MyUser()
                self.isSigningIn = false
            }
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }

    func signIn() async {
        do {
            let signedInUser = try await authService.signIn(
                email: myUser.email,
                password: myUser.password,
                username: myUser.username
            )
//            DispatchQueue.main.async {
                self.falseCredential = false
                self.myUser = signedInUser
                self.user = Auth.auth().currentUser
                self.isSigningIn = true
//            }
        } catch {
//            DispatchQueue.main.async {
                print("SignIn error: \(error.localizedDescription)")
                self.falseCredential = true
                self.isSigningIn = false
//            }
        }
    }

    func signUp() async {
        guard !petName.isEmpty else {
            DispatchQueue.main.async {
                print("Pet name is required for sign up")
                self.falseCredential = true
            }
            return
        }

        do {
            let signedUpUser = try await authService.signUp(
                email: myUser.email,
                password: myUser.password,
                username: myUser.username,
                petName: petName
            )
//            DispatchQueue.main.async {
                self.falseCredential = false
                self.myUser = signedUpUser
                self.user = Auth.auth().currentUser
                self.isSigningIn = true
//            }
        } catch {
            DispatchQueue.main.async {
                print("SignUp error: \(error.localizedDescription)")
                self.falseCredential = true
                self.isSigningIn = false
            }
        }
    }

}
