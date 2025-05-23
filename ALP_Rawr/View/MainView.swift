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
                    Image(systemName: "house")
                    Text("Home")
                }
            
            SocialView()
                .tabItem{
                    Image(systemName: "house")
                }
            
            ProfileView(showAuthSheet: $showAuthSheet)
                .tabItem {
                    Image(systemName: "person")
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
        .environmentObject(PetHomeViewModel())
}
