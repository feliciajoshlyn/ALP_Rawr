//
//  AuthViewModel.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import Foundation
import FirebaseAuth
@MainActor
class AuthViewModel: ObservableObject {
    
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
    
    func signIn() async {
        do{
            _ = try await Auth.auth().signIn(withEmail: myUser.email, password: myUser.password)
            
            DispatchQueue.main.async {
                self.falseCredential = false
            }
        } catch {
            DispatchQueue.main.async {
                self.falseCredential = true
            }
            
        }
    }
    
    func signUp() async {
        do{
            _ = try await Auth.auth().createUser(withEmail: myUser.email, password: myUser.password)
            
            DispatchQueue.main.async {
                self.falseCredential = false
            }
        } catch {
            DispatchQueue.main.async {
                self.falseCredential = true
            }
            
        }
    }
}
