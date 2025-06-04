//
//  SwiftUIView.swift
//  ALP_RawrWatchApp Watch App
//
//  Created by Gerald Gavin Lienardi on 31/05/25.
//

import SwiftUI
import WatchConnectivity

struct DiaryWatchView: View {
    @StateObject var diaryWatchViewModel: iOSConnectivity
        
    var body: some View {
        NavigationStack{
            VStack{
                if diaryWatchViewModel.diary.isEmpty {
                    VStack(spacing: 2) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No diary entries yet")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Open iPhone app to sync")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                } else {
                    List {
                        ForEach(diaryWatchViewModel.diary, id: \.id) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.title)
                                    .font(.headline)
                                Text(entry.text)
                                    .font(.caption)
                                    .lineLimit(2)
                                    .foregroundColor(.secondary)
                                Text(entry.createdAt, style: .date)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                NavigationLink("See Friends", destination: FriendWatchView(diaryWatchViewModel: iOSConnectivity()))
                
            }
            .navigationTitle("My Diary")


        }
        .onAppear {
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(["request": "diaryEntries"], replyHandler: nil) { error in
                    print("Failed to request diary entries: \(error.localizedDescription)")
                }
            }
        }

    }
}

#Preview {
    DiaryWatchView(diaryWatchViewModel: iOSConnectivity())
}
