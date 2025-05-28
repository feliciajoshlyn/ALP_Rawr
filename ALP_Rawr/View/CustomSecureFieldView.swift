//
//  CustomSecureFieldView.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 28/05/25.
//

import SwiftUI

struct CustomSecureFieldView: View {
    let title: String
    @Binding var text: String
    let icon: String
    @State private var isSecure: Bool = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Group {
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    CustomSecureFieldView(title: "", text: .constant(""), icon: "")
}
