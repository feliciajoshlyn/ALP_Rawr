//
//  ContentView.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var diaryWatchViewModel: DiaryWatchViewModel
    @EnvironmentObject private var petWatchViewModel: PetWatchViewModel
    @EnvironmentObject private var connectivityManager: WatchConnectivityManager
    @ObservedObject var connectivity: iOSConnectivity
    @State private var showPet: Bool = false
    @State private var showDiary: Bool = false
    @State private var showWalk: Bool = false
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("Welcome to Monchi on the go!")
                    .padding(.bottom, 8)
                Button(action: {
                    showPet = true
                }){
                    Text("View Pet")
                }
                Button(action: {
                    showDiary = true
                }){
                    Text("View Diary")
                }
                Button(action: {
                    showWalk = true
                }){
                    Text("Walk the Dog")
                }
            }
            .navigationDestination(isPresented: $showPet) {
                PetView(petWatchViewModel: self.petWatchViewModel, showPet: $showPet)
            }
            .navigationDestination(isPresented: $showDiary){
                DiaryWatchView(diaryWatchViewModel: self.diaryWatchViewModel)
            }
            .navigationDestination(isPresented: $showWalk){
                WatchWalkingView(connectivity: connectivity)
                    .environmentObject(connectivityManager)
            }
        }
    }
}

#Preview {
    ContentView(connectivity: iOSConnectivity())
}
