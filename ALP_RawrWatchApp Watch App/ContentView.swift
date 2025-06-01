//
//  ContentView.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var diaryWatchViewModel: DiaryWatchViewModel = DiaryWatchViewModel()
    @StateObject private var iOSConnectivityManager: iOSConnectivity = iOSConnectivity()
    @State private var showPet: Bool = false
    @State private var showDiary: Bool = false
    
    
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
                    showPet = true
                }){
                    Text("View Diary")
                }
            }
            .navigationDestination(isPresented: $showPet) {
                PetView(iOSConnectivityManager: self.iOSConnectivityManager, showPet: $showPet)
            }
            .navigationDestination(isPresented: $showDiary){
                DiaryWatchView(diaryWatchViewModel: self.diaryWatchViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
