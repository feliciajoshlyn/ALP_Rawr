//
//  MyUser.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//


import Foundation
struct MyUser: Identifiable {
    var id: String { uid }
    var uid: String  = ""
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var friends: [String] = []
    
}
