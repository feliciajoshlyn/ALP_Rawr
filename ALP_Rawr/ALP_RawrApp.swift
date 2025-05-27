//
//  ALP_RawrApp.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct ALP_RawrApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init(){
        FirebaseApp.configure()
        //untuk load plist
        
        #if DEBUG
        let provider = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(provider)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
