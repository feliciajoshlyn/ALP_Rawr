//
//  MainView.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var showAuthSheet = false
    
    var body: some View {
        TabView{
            PetHomeView()
                .tabItem{
                    Image(systemName: "pawprint.fill")
                    Text("Home")
                }
            
            EmotionGalleryView()
                .tabItem{
                    Image(systemName: "book.pages")
                    Text("Emotions")
                }
            
            MapView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Walk with Me")
                }
            
            DiaryView()
                .tabItem{
                    Image(systemName: "person.2.fill")
                    Text("Social")
                }
            
            ProfileView(showAuthSheet: $showAuthSheet)
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
            
        }
        .onAppear{
            showAuthSheet = !authViewModel.isSigningIn
        }
        .fullScreenCover(isPresented: $showAuthSheet){
            LoginRegisterSheet(showAuthSheet: $showAuthSheet)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
        .environmentObject(PetHomeViewModel(petService: LivePetService()))
        .environmentObject(LocationViewModel())
        .environmentObject(DiaryViewModel())
}
