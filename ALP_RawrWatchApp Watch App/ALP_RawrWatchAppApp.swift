//
//  ALP_RawrWatchAppApp.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by student on 30/05/25.
//

import SwiftUI

@main
struct ALP_RawrWatchApp_Watch_AppApp: App {
//    @StateObject var watchConnectivityManager = WatchConnectivityManager.shared
    @StateObject var connectivityManager = iOSConnectivity()
    @StateObject var diaryWatchViewModel: DiaryWatchViewModel = DiaryWatchViewModel()
//    @StateObject private var petWatchViewModel: PetWatchViewModel = PetWatchViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(connectivity: connectivityManager)
//                .environmentObject(watchConnectivityManager)
                .environmentObject(diaryWatchViewModel)
//                .environmentObject(petWatchViewModel)
        }
    }
}
