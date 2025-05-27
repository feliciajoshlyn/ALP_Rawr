//
//  MyUser.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//


import Foundation
struct MyUser{
    var uid : String = ""
    var username: String = ""
    var email: String = ""
    var password : String = ""
    var friends : [String] = []
    //tidak perlu token karena dimanage oleh firebase
}
