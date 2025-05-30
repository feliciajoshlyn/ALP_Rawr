//
//  ContentView.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var iOSConnectivityManager: iOSConnectivity = iOSConnectivity()
    @State private var showPet: Bool = false
    
    
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
            }
            .navigationDestination(isPresented: $showPet) {
                PetView(iOSConnectivityManager: self.iOSConnectivityManager, showPet: $showPet)
            }
        }
    }
}

#Preview {
    ContentView()
}
