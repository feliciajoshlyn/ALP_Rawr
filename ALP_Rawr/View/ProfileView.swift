//
//  ProfileView.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var petHomeViewModel: PetHomeViewModel
    @Binding var showAuthSheet: Bool
    
    var body: some View {
        Button(action: {
            Task {
                petHomeViewModel.savePet()
                authViewModel.signOut()
                authViewModel.checkUserSession()
                showAuthSheet = !authViewModel.isSigningIn
            }
        }){
            Text("Log Out")
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
    }
}

#Preview {
    ProfileView(showAuthSheet: .constant(true))
        .environmentObject(AuthViewModel())
        .environmentObject(PetHomeViewModel())
}
