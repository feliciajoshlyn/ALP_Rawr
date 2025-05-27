//
//  DiaryViewModel.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import Foundation

class DiaryViewModel : ObservableObject{
    @Published var diary: [DiaryEntry] = []
    @Published var friends: [String] = []

    @Published var isLoading = false
    
    private let diaryService = DiaryService.shared
    
    func loadEntries(for userId: String) {
        isLoading = true
        
        diaryService.fetchFriends(userId: userId) { friends in
            self.diaryService.fetchDiaryWithFriends(userId: userId, friends: friends) { entries in
                DispatchQueue.main.async {
                    self.diary = entries
                    self.isLoading = false
                }
            }
        }
    }
    
    func addEntry(_ entry: DiaryEntry) {
        diaryService.addDiaryEntry(_entry: entry) { success in
            DispatchQueue.main.async {
                if success {
                    print("Diary Entry added Successfully")
                } else {
                    print("Failed to add Diary Entry")
                }
            }
        }
    }
    
    func loadReactions(for entryId: String) {
        diaryService.fetchReactions(toEntryId: entryId) { reactions in
            DispatchQueue.main.async {
                if let index = self.diary.firstIndex(where: { $0.id == entryId }) {
                    self.diary[index].reactions = reactions
                }
            }
        }
    }
    
    func addReaction(to entryId: String, _ reaction: Reaction) {
        diaryService.addReaction(toEntryId: entryId, reaction: reaction) {success in
            if success {
                print("Successfully added reaction")
            } else {
                print("Failed to add reaction")
            }
        }
    }
    
    func addFriend(from currentUserId: String, to friendId: String) {
        diaryService.addFriend(currentUserId: currentUserId, friendId: friendId) {success in
            if success {
                print( "Successfully added friend")
            } else {
                print( "Failed to add friend")
            }
        }
    }
    
    func showFriends(for userId: String){
        diaryService.fetchFriends(userId: userId) { friends in
            DispatchQueue.main.async {
                self.friends = friends
            }
        }
    }
    
}
