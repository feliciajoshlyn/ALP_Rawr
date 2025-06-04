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
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var diaryViewModel = DiaryViewModel()
    @StateObject private var walkViewModel = WalkingViewModel()
    @StateObject private var agePredictionViewModel = AgePredictionViewModel()
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    
    init(){
        FirebaseApp.configure()
        //untuk load plist
        
        #if DEBUG
        let provider = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(provider)
        #endif
        
        let petService = LivePetService()
        let userService = UserService()
        let authService = AuthService(userService: userService, petService: petService)
               
        //        _authViewModel = StateObject(wrappedValue: AuthViewModel(petService: petService, userService: userService))
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
        _petHomeViewModel = StateObject(wrappedValue: PetHomeViewModel(petService: petService))
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(authViewModel)
                .environmentObject(petHomeViewModel)
                .environmentObject(locationViewModel)
                .environmentObject(diaryViewModel)
                .environmentObject(walkViewModel)
                .environmentObject(agePredictionViewModel)
                .environmentObject(connectivityManager)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    if authViewModel.isSigningIn, let user = authViewModel.user {
                        petHomeViewModel.savePet()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    if authViewModel.isSigningIn, let user = authViewModel.user {
                        petHomeViewModel.refetchPetData()
                    }
                }
        }
    }
}
