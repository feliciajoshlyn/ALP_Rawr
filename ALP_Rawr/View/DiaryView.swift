//
//  DiaryView.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import SwiftUI
import FirebaseCore

struct DiaryView: View {
    @EnvironmentObject var diaryViewModel: DiaryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showingAddFriendSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(diaryViewModel.diary, id: \.id) { entry in
                        EntryCard(diaryEntry: entry)
                            .padding(.horizontal, 20)
                    }
                    
                    if diaryViewModel.diary.isEmpty {
                        emptyStateView
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("My Diary ⭐️")
            .onAppear {
                diaryViewModel.loadEntries(for: authViewModel.myUser.uid)
            }
            .refreshable {
                diaryViewModel.loadEntries(for: authViewModel.myUser.uid)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddFriendSheet = true
                    }) {
                        Label("Add Friend", systemImage: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFriendSheet) {
                AddFriendView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No diary entries yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Do some activities!")
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
    }
}

// Example AddFriendView (customize this)
struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Add your friends here!")
                .navigationTitle("Add Friend")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}


#Preview {
    DiaryView()
        .environmentObject(DiaryViewModel())
        .environmentObject(AuthViewModel())
}
