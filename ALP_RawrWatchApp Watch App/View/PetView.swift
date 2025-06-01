//
//  PetView.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by Dapur Gili on 30/05/25.
//

import SwiftUI

struct PetView: View {
    @ObservedObject var iOSConnectivityManager: iOSConnectivity
    @Binding var showPet: Bool
    
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack{
                Image("dog_inplace_left")
                    .resizable()
                    .scaledToFit()
                
                HStack{
                    Button(action: {}){
                        Text("Pet Me")
                    }
                    Button(action: {}){
                        Text("Feed Me")
                    }
                }
            }
        }
    }
}

#Preview {
    PetView(iOSConnectivityManager: iOSConnectivity(), showPet: .constant(true))
}
