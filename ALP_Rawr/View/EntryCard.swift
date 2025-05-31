//
//  EntryCard.swift
//  ALP_Rawr
//
//  Created by student on 23/05/25.
//

import SwiftUI

struct EntryCard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    var diaryEntry: DiaryEntry
    var userReaction: Reaction?
//    let likesCount: Int
//    let commentsCount: Int
//    let timeAgo: String
    @State private var isLiked = true
    @State private var uid = ""
    @State private var username: String = "Loading..."

    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("uid: \(uid)")
            HStack {
                Text(username)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                
                Spacer()
                
//                Text("created at")
//                    .font(.system(size: 12))
//                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(diaryEntry.text)
                    .font(.system(size: 14, weight: .regular))
                    .lineLimit(nil)
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isLiked.toggle()
                        }
                        diaryViewModel.addReaction(to: diaryEntry.id, Reaction(
                            id: authViewModel.user?.uid ?? "",
                            data:[
                                "userId": authViewModel.user?.uid ?? "",
                                "liked": isLiked,
                                "comment": "",
                                "createdAt": Date()
                            ])
                        )
                        diaryViewModel.loadReaction(for: diaryEntry.id, userId: authViewModel.user?.uid ?? "")
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .pink : .secondary)
                                .font(.system(size: 16))
                                .scaleEffect(isLiked ? 1.1 : 1.0)
                            
                            Text("\(diaryEntry.likesCount)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Comment button
                    Button(action: {
                        // Comment action
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                            
//                            Text("\(commentsCount)")
//                                .font(.system(size: 12, weight: .medium))
//                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.pink.opacity(0.4), .purple.opacity(0.3), .blue.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .onAppear {
            // Load the user's reaction for this entry
            diaryViewModel.loadReaction(for: diaryEntry.id, userId: authViewModel.user?.uid ?? "hyju")
            // Fetch username
            DiaryService.shared.searchUser(byUID: diaryEntry.userId) { user in
                DispatchQueue.main.async {
                    self.username = user?.username ?? "Unknown"
                }
            }

//            // Update UI after loading user reaction (if available in cache already)
//            if let reaction = diaryViewModel.userReactions[diaryEntry.id]
//            {
//                isLiked = reaction.isLiked
//                uid = reaction.userId
//            } else {
//                isLiked = false
//            }
            isLiked = userReaction?.isLiked ?? false
        }
        
    }


}

#Preview {
//    VStack(spacing: 16) {
//        EntryCard(
//            entryText: "Today I found a really cool butterfly in the garden! It had orange and black wings and it sat on my finger for like 5 whole seconds! 🦋✨",
//            likesCount: 12,
//            commentsCount: 3,
//            timeAgo: "2h ago"
//        )
//        .environmentObject(AuthViewModel())
//        
//        EntryCard(
//            entryText: "My dog learned a new trick today! He can now roll over AND play dead. Mom says he's the smartest dog ever 🐕💫",
//            likesCount: 8,
//            commentsCount: 5,
//            timeAgo: "4h ago"
//        )
//        .environmentObject(AuthViewModel())
//    }
//    .padding()
//    .background(Color(.systemGroupedBackground))
}
