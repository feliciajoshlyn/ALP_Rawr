//
//  EmotionDetailView.swift
//  ALP_Rawr
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct EmotionDetailView: View {
    @State var emotion: EmotionModel = EmotionModel(
        name: "Happy",
        description: "Happy is when you feel really good, like when you play with your friends or get a hug.",
        copingStrategies: [
            "Smile and enjoy the moment",
            "Share your joy with others",
            "Say thank you to someone who helped you"
        ],
        color: .orange, // Changed from yellow for better contrast
        cardImage: "happycard"
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 16) {
                    Image(emotion.cardImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .shadow(color: emotion.color.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Text(emotion.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(emotion.color)
                }
                
                // Description Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "quote.bubble.fill")
                            .foregroundColor(emotion.color)
                        Text("What does this feel like?")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Text(emotion.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(emotion.color.opacity(0.1))
                        )
                }
                
                // Coping Strategies Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(emotion.color)
                        Text("Ways to handle this feeling")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(Array(emotion.copingStrategies.enumerated()), id: \.offset) { index, strategy in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(emotion.color)
                                    .clipShape(Circle())
                                
                                Text(strategy)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    emotion.color.opacity(0.05),
                    Color(.systemBackground)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    EmotionDetailView()
}
