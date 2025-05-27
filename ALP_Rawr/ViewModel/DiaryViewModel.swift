//
//  DiaryViewModel.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import Foundation

class DiaryViewModel : ObservableObject{
    @Published var diary: [DiaryEntry] = []
    @Published var isLoading = false
    
    private let diaryService = DiaryService.shared
    
        
    func loadEntries(for userId: String) {
        isLoading = true
        diaryService.fetchDiaryEntries(forUserId: userId) { entries in
            DispatchQueue.main.async {
                self.diary = entries
                self.isLoading = false
            }
        }
    }
    
    func addEntry(_ entry: DiaryEntry) {
        diaryService.addDiaryEntry(_entry: entry) { success in
            DispatchQueue.main.async {
                if success {
                    print("Diary Entry added Successfully")
                    // Optionally reload entries or add the entry to the local array
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
    
}
