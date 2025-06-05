//
//  LoginRegisterSheet.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import SwiftUI

struct LoginRegisterSheet: View {
    @Binding var showAuthSheet: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLoginMode: Bool = true
    @State private var isLoading: Bool = false
    
    private var isFormValid: Bool {
        if isLoginMode {
            return !authViewModel.myUser.email.isEmpty && !authViewModel.myUser.password.isEmpty
        } else {
            return !authViewModel.petName.isEmpty &&
                   !authViewModel.myUser.email.isEmpty &&
                   !authViewModel.myUser.password.isEmpty
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image("defaultprofile")
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(4, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                        
                        Text(isLoginMode ? "Welcome Back" : "Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(isLoginMode ? "Sign in to your account" : "Join us and manage your pet's care")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .animation(.easeInOut(duration: 0.3), value: isLoginMode)
                    
                    // Mode toggle
                    ZStack {
                        // Background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                        
                        // Sliding indicator
                        HStack {
                            if isLoginMode {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                                    .frame(maxWidth: .infinity)
                                Spacer()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Spacer()
                                    .frame(maxWidth: .infinity)
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(4)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoginMode)
                        
                        // Buttons
                        HStack(spacing: 0) {
                            Button(action: { withAnimation(.spring()) { isLoginMode = true } }) {
                                Text("Login")
                                    .font(.headline)
                                    .fontWeight(isLoginMode ? .semibold : .regular)
                                    .foregroundColor(isLoginMode ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            
                            Button(action: { withAnimation(.spring()) { isLoginMode = false } }) {
                                Text("Register")
                                    .font(.headline)
                                    .fontWeight(!isLoginMode ? .semibold : .regular)
                                    .foregroundColor(!isLoginMode ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                        }
                    }
                    .frame(height: 44)
                    
                    // Form content
                    VStack(spacing: 20) {
                        if isLoginMode {
                            VStack(spacing: 16) {
                                CustomTextFieldView(
                                    title: "Email",
                                    text: $authViewModel.myUser.email,
                                    icon: "envelope.fill",
                                    keyboardType: .emailAddress
                                )
                                
                                CustomSecureFieldView(
                                    title: "Password",
                                    text: $authViewModel.myUser.password,
                                    icon: "lock.fill"
                                )
                                
                                if authViewModel.falseCredential {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red)
                                        Text("Invalid email or password")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.red.opacity(0.1))
                                    )
                                }
                            }
                        } else {
                            VStack(spacing: 16) {
                                CustomTextFieldView(
                                    title: "Username",
                                    text: $authViewModel.myUser.username,
                                    icon: "person.fill"
                                )
                                
                                CustomTextFieldView(
                                    title: "Email",
                                    text: $authViewModel.myUser.email,
                                    icon: "envelope.fill",
                                    keyboardType: .emailAddress
                                )
                                
                                CustomSecureFieldView(
                                    title: "Password",
                                    text: $authViewModel.myUser.password,
                                    icon: "lock.fill"
                                )
                                
                                CustomTextFieldView(
                                    title: "Pet's Name",
                                    text: $authViewModel.petName,
                                    icon: "pawprint.fill"
                                )
                                
                                if authViewModel.falseCredential {
                                    HStack {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.red)
                                            Text("Registration failed. Please check your information.")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.red.opacity(0.1))
                                        )
                                }
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: isLoginMode)
                    
                    // Action button
                    Button(action: {
                        isLoading = true
                        authViewModel.falseCredential = false
                        
                        Task {
                            if isLoginMode {
                                await authViewModel.signIn()
                                if !authViewModel.falseCredential {
                                    authViewModel.checkUserSession()
                                    showAuthSheet = !authViewModel.isSigningIn
                                    authViewModel.myUser = MyUser()
                                }
                            } else {
                                await authViewModel.signUp()
                                if !authViewModel.falseCredential {
                                    authViewModel.checkUserSession()
                                    showAuthSheet = !authViewModel.isSigningIn
                                    authViewModel.myUser = MyUser()
                                }
                            }
                            
                            await MainActor.run {
                                isLoading = false
                                
                                if !authViewModel.falseCredential {
                                    authViewModel.checkUserSession()
                                    showAuthSheet = !authViewModel.isSigningIn
                                    authViewModel.myUser = MyUser()
                                }
                            }
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: isLoginMode ? "arrow.right.circle.fill" : "person.badge.plus.fill")
                                    .font(.headline)
                            }
                            
                            Text(isLoginMode ? "Sign In" : "Create Account")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .disabled(isLoading || !isFormValid)
                    .opacity(isLoading || !isFormValid ? 0.6 : 1.0)
                    .animation(.easeInOut, value: isLoading)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
    }
}

#Preview {
    LoginRegisterSheet(showAuthSheet: .constant(true))
        .environmentObject(AuthViewModel())
}
