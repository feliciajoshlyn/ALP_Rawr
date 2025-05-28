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
    @StateObject private var petHomeViewModel = PetHomeViewModel()
    
    init(){
        FirebaseApp.configure()
        //untuk load plist
        
        #if DEBUG
        let provider = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(provider)
        #endif
        
        let petService = PetService()
        _authViewModel = StateObject(wrappedValue: AuthViewModel(petService: petService))
        _petHomeViewModel = StateObject(wrappedValue: PetHomeViewModel(petService: petService))
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(authViewModel)
                .environmentObject(petHomeViewModel)
//                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
//                    if authViewModel.isSigningIn {
//                        petHomeViewModel.savePet()
//                    }
//                }
//                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
//                    if authViewModel.isSigningIn {
//                        petHomeViewModel.refetchPetData()
//                    }
//                }
        }
    }
}
