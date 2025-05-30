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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddFriendSheet = true
                    }) {
                        Label("My Friends", systemImage: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFriendSheet) {
                AddFriendView()
            }
            .onAppear {
                if let user = authViewModel.user {
                    diaryViewModel.loadEntries(for: user.uid)
                }
            }
            .refreshable {
                diaryViewModel.loadEntries(for: authViewModel.user?.uid ?? "")
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

// MARK: - Add Friend View

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var diaryViewModel: DiaryViewModel

    @State private var searchUID = ""
    @State private var didSearch = false
    @State private var disableSearch = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Search Field
                TextField("Enter friend's UID", text: $searchUID)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.default)
                    .onChange(of: searchUID) {
                        didSearch = false
                        if !searchUID.isEmpty{
                            disableSearch = false
                        } else {
                            disableSearch = true
                        }
                    }

                Button("Search Friend") {
                    didSearch = true
                    diaryViewModel.searchFriend(by: searchUID)
                }
                .disabled(disableSearch)

                if didSearch {
                    if let friend = diaryViewModel.searchedFriend {
                        VStack(spacing: 8) {
                            Text("Found: \(friend.username)")
                                .fontWeight(.medium)

                            if diaryViewModel.friends.contains(where: { $0.uid == friend.uid }) {
                                Text("✅ Already friends")
                                    .foregroundColor(.green)
                                    .font(.subheadline)
                            } else {
                                Button("Add Friend") {
                                    diaryViewModel.addFriendButtonAction(
                                        currentUserId: authViewModel.myUser.uid,
                                        friendId: friend.uid
                                    )
                                    diaryViewModel.fetchCurrentUserFriends(currentUserId: authViewModel.myUser.uid)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    } else {
                        Text("No user found")
                            .foregroundColor(.secondary)
                    }
                }

                Divider().padding(.vertical)

                // Friend List
                Text("Your Friends:")
                    .font(.headline)

                if diaryViewModel.friends.isEmpty {
//                    ProgressView("Loading friends...")
                    Text("No friends")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(diaryViewModel.friends.enumerated()), id: \.element.id) { index, friend in
                                VStack(spacing: 0) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "person.crop.circle")
                                            .font(.system(size: 28))
                                            .foregroundColor(.accentColor)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(friend.username)
                                                .font(.body)
                                                .fontWeight(.medium)
                                            Text(friend.uid)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemBackground))

                                    if index < diaryViewModel.friends.count - 1 {
                                        Divider()
                                            .padding(.leading, 52) // indent divider to align with text
                                    }
                                }
                                .background(Color(.secondarySystemGroupedBackground)) // subtle background like List
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }


                }

                Spacer()
            }
            .padding()
            .navigationTitle("My Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                diaryViewModel.fetchCurrentUserFriends(currentUserId: authViewModel.myUser.uid)
            }
        }
    }
}



#Preview {
    DiaryView()
        .environmentObject(DiaryViewModel())
        .environmentObject(AuthViewModel()) // add dummy/mock AuthViewModel if needed
}


