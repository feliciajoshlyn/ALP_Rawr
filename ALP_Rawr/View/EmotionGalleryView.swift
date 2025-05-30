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
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(emotionGalleryViewModel.emotions, id: \.name) { emotion in
                        VStack {
                            Image(emotion.cardImage)
                                .resizable()
                                .scaledToFit()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(maxWidth: .infinity)
                            Text(emotion.name)
                                .foregroundColor(emotion.color)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Emotion Gallery")
        }
    }
}

#Preview {
    EmotionGalleryView()
}
