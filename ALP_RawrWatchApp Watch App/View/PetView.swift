//
//  PetView.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by Dapur Gili on 30/05/25.
//

import SwiftUI

struct PetView: View {
    @ObservedObject var petWatchViewModel: iOSConnectivity
    @Binding var showPet: Bool
    
    var body: some View {
        ScrollView{
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack{
                    HStack(alignment: .top){
                        Text("\(petWatchViewModel.pet.name)")
                        VStack{
                            Text("Hunger:")
                            Text("\(Int(petWatchViewModel.pet.hunger))")
                        }
                    }
                    
                    Image("dog_inplace_left")
                        .resizable()
                        .scaledToFit()
                    
                    HStack{
                        Button(action: {
                            petWatchViewModel.sendPetToiOS()
                        }){
                            Text("Pet Me")
                        }
                        Button(action: {
                            petWatchViewModel.sendFeedToiOS()
                        }){
                            Text("Feed Me")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PetView(petWatchViewModel: iOSConnectivity(), showPet: .constant(true))
}
