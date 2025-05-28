//
//  StatusCardView.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 28/05/25.
//

import SwiftUI

struct StatusCardView: View {
    let title: String
    let value: Int
    let maxValue: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Progress bar
            ProgressView(value: Double(value), total: Double(maxValue))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 0.8)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
}

#Preview {
    StatusCardView(title: "", value: 0, maxValue: 100, color: .blue, icon: "")
}
