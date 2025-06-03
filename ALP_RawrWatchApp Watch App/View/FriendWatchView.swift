//
//  FriendWatchView.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by Gerald Gavin Lienardi on 31/05/25.
//

import SwiftUI
import WatchConnectivity

struct FriendWatchView: View {
    @StateObject var diaryWatchViewModel: iOSConnectivity

    var body: some View {
        NavigationStack{
            List {
                if diaryWatchViewModel.friends.isEmpty {
                    Text("No friends")
                        .foregroundColor(.gray)
                } else {
                    ForEach(0..<diaryWatchViewModel.friends.count, id: \.self) { index in
                        let friend = diaryWatchViewModel.friends[index]
                        VStack(alignment: .leading, spacing: 4) {
                            Text(friend["username"] as? String ?? "Unknown")
                                .font(.headline)
                            Text(friend["uid"] as? String ?? "No UID")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .toolbar{
                ToolbarItem(placement: .confirmationAction) {
                    NavigationLink("+", destination: AddFriendWatchView( diaryWatchViewModel: diaryWatchViewModel))
                }
            }
            .navigationTitle("Friends")
            .onAppear {
                if WCSession.default.isReachable {
                    WCSession.default.sendMessage(["request": "diaryEntries"], replyHandler: nil) { error in
                        print("Failed to request diary entries: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

#Preview {
    FriendWatchView(diaryWatchViewModel: iOSConnectivity())
}
