//
//  AuthViewModel.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import Foundation
import FirebaseAuth
@MainActor
class authViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isSigningIn: Bool
    @Published var myUser: MyUser
    @Published var falseCredential: Bool
    
    init(){
        self.user = nil
        self.isSigningIn = false
        self.falseCredential = false
        self.myUser = MyUser()
        self.checkUserSession()
    }
    
    func checkUserSession(){
        //check jika pernah login, kl login akan return user
        self.user = Auth.auth().currentUser
        self.isSigningIn = true
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
        }catch {
            
        }
    }
}
