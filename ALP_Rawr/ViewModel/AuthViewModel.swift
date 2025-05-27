//
//  AuthViewModel.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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
        do {
            let result = try await Auth.auth().signIn(withEmail: myUser.email, password: myUser.password)
            let user = result.user

            //access firestore
            let db = Firestore.firestore()
            //get firestore sesuai dengan nama uid like users/uid spt id
            let userRef = db.collection("users").document(user.uid)
            //wait so they get the document
            let snapshot = try await userRef.getDocument()
            
            //if missing
            if !snapshot.exists {
                //set data utk user uid tersebut
                try await userRef.setData([
                    "email": user.email ?? "",
                    "username": myUser.username,
                    "friends": []
                ])
            }

            DispatchQueue.main.async {
                self.falseCredential = false
                self.user = user
                self.myUser.uid = user.uid
            }
        } catch {
            DispatchQueue.main.async {
                self.falseCredential = true
            }
        }
    }

    
    func signUp() async {
        do {
            let result = try await Auth.auth().createUser(withEmail: myUser.email, password: myUser.password)
            let user = result.user
            
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            try await userRef.setData([
                "email": user.email ?? "",
                "username": myUser.username,
                "friends": []
            ])
            
            DispatchQueue.main.async {
                self.falseCredential = false
                self.user = user
                self.myUser.uid = user.uid
            }
        } catch {
            DispatchQueue.main.async {
                self.falseCredential = true
            }
        }
    }

}
