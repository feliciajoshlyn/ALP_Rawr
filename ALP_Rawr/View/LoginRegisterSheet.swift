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
    @State var registerClicked: Bool = true

    var body: some View {
        if registerClicked {
            VStack {
                Text("Login")
                    .font(.title)

                TextField("Email", text: $authViewModel.myUser.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $authViewModel.myUser.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if authViewModel.falseCredential {
                    Text("Invalid Username and Password")
                        .fontWeight(.medium)
                        .foregroundColor(Color.red)
                }

                Button(
                    action: {
                        Task {
                            await authViewModel.signIn()
                            if !authViewModel.falseCredential {
                                authViewModel.checkUserSession()
                                showAuthSheet = !authViewModel.isSigningIn
                                authViewModel.myUser = MyUser()
                            }
                        }
                    }
                ) {
                    Text("Login").frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .buttonStyle(.borderedProminent)

                Spacer()

                Button(
                    action: {
                        registerClicked = false
                    }
                ) {
                    Text("Register")
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                }
            }
            .interactiveDismissDisabled(true)

        } else {
            VStack {
                Text("Register")
                    .font(.title)

                TextField("Username", text: $authViewModel.myUser.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Email", text: $authViewModel.myUser.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $authViewModel.myUser.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if authViewModel.falseCredential {
                    Text("Invalid Username and Password")
                        .fontWeight(.medium)
                        .foregroundColor(Color.red)
                }

                Button(
                    action: {
                        Task {
                            await authViewModel.signUp()
                            if !authViewModel.falseCredential {
                                authViewModel.checkUserSession()
                                showAuthSheet = !authViewModel.isSigningIn
                                authViewModel.myUser = MyUser()
                            }
                        }
                    }
                ) {
                    Text("Register").frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .buttonStyle(.borderedProminent)

                Spacer()

                Button(
                    action: {
                        registerClicked = true
                    }
                ) {
                    Text("Login")
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                }
                .interactiveDismissDisabled(true)
            }
        }
    }
}

#Preview {
    LoginRegisterSheet(showAuthSheet: .constant(true))
        .environmentObject(AuthViewModel())
}
