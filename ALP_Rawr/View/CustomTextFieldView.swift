//
//  CustomTextFieldView.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 28/05/25.
//

import SwiftUI

struct CustomTextFieldView: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
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
    CustomTextFieldView(title: "", text: .constant(""), icon: "")
}
