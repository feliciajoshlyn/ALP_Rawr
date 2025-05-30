//
//  EmotionGalleryView.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import SwiftUI

struct EmotionGalleryView: View {
    @StateObject var emotionGalleryViewModel = EmotionGalleryViewModel()

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(emotionGalleryViewModel.emotions, id: \.name) { emotion in
                        NavigationLink(destination: EmotionDetailView(emotion: emotion)) {
                            VStack(spacing: 12) {
                                // Image Container
                                ZStack {
                                    Image(emotion.cardImage)
                                        .resizable()
                                        .scaledToFit()
                                        .aspectRatio(1, contentMode: .fit)
                                }
                                .shadow(color: emotion.color.opacity(0.4), radius: 12, x: 0, y: 2)
                                
                                Text(emotion.name)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.1), value: emotion.name)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGroupedBackground),
                        Color(.systemBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("How are you feeling?")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    EmotionGalleryView()
}
