//
//  SplashScreenView.swift
//  ALP_Rawr
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var connectivityManager: WatchConnectivityManager
    @EnvironmentObject var locationViewModel: LocationViewModel
    @EnvironmentObject var agePredictionViewModel: AgePredictionViewModel
    @EnvironmentObject var walkViewModel: WalkingViewModel
    @EnvironmentObject var petHomeViewModel: PetHomeViewModel
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    
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
                
                Task { @MainActor in
                    connectivityManager.injectViewModels(
                        locationVM: locationViewModel,
                        agePredictionVM: agePredictionViewModel,
                        walkingVM: walkViewModel,
                        petHomeVM: petHomeViewModel,
                        diaryVM: diaryViewModel
                    )
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(AuthViewModel())
        .environmentObject(PetHomeViewModel(petService: LivePetService()))
        .environmentObject(LocationViewModel())
        .environmentObject(DiaryViewModel())
}
