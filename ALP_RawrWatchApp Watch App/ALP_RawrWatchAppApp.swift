//
//  ALP_RawrWatchAppApp.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by student on 30/05/25.
//

import SwiftUI

@main
struct ALP_RawrWatchApp_Watch_AppApp: App {
    @StateObject var watchConnectivityManager = WatchConnectivityManager.shared
    @StateObject var connectivityManager = iOSConnectivity()
    
    var body: some Scene {
        WindowGroup {
            WatchWalkingView(connectivity: connectivityManager)
                .environmentObject(watchConnectivityManager)
        }
    }
}
