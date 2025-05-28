//
//  ALP_RawrApp.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import SwiftUI

@main
struct ALP_RawrApp: App {
    @StateObject private var locationViewModel = LocationViewModel()
    var body: some Scene {
        WindowGroup {
            MapView()
                .environmentObject(locationViewModel)
        }
    }
}
