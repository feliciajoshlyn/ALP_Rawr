//
//  SplashScreenView.swift
//  ALP_Rawr
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State var isActive: Bool = false
    
    var body: some View {
        if isActive {
            MainView()
        } else {
            ZStack{
                Rectangle()
                    .foregroundColor(.blue.opacity(0.1))
                    .ignoresSafeArea()
                
                Image("splashscreen")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea(edges: .all)
                    .padding(64)
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.4){
                    withAnimation{
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(AuthViewModel())
        .environmentObject(PetHomeViewModel(petService: PetService()))
        .environmentObject(LocationViewModel())
        .environmentObject(DiaryViewModel())
}
