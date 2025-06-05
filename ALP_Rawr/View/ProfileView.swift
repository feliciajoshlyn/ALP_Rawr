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
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Spacer().frame(height: 40)
                    
                    Image("defaultpfp")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 220)
                        .clipShape(Circle())
                
                .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
                    
                    Text(authViewModel.user?.displayName ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .primary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text(authViewModel.user?.uid ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer().frame(height: 10)
                }
                .padding(.horizontal, 24)
                
                // Information Cards Section
                VStack(spacing: 16) {
                    // Email Card
                    InfoCard(
                        icon: "envelope.fill",
                        title: "Email Address",
                        content: authViewModel.user?.email ?? "",
                        iconColor: .blue,
                        backgroundColor: Color.blue.opacity(0.05)
                    )
                    
                    // Pet Bond Card
                    InfoCard(
                        icon: "heart.fill",
                        title: "Pet Bond Level",
                        content: Int(petHomeViewModel.pet.bond).description,
                        iconColor: .pink,
                        backgroundColor: Color.pink.opacity(0.05)
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 60)
                
                // Logout Button
                Button(action: {
                    showLogoutConfirmation = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Log Out")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .red.opacity(0.25), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 40)
            }
        }
        .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
            Button("Log Out", role: .destructive) {
                Task {
                    petHomeViewModel.savePet()
                    petHomeViewModel.resetViewModel()
                    authViewModel.signOut()
                    authViewModel.checkUserSession()
                    showAuthSheet = !authViewModel.isSigningIn
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

// Custom Info Card Component
struct InfoCard: View {
    let icon: String
    let title: String
    let content: String
    let iconColor: Color
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Container
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(content)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ProfileView(showAuthSheet: .constant(true))
        .environmentObject(AuthViewModel())
        .environmentObject(PetHomeViewModel())
}
