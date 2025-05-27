//
//  DiaryViewModel.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 27/05/25.
//

import Foundation

class DiaryViewModel : ObservableObject{
    @Published var diary: [DiaryEntry] = []
    
    private let diaryService = DiaryService.shared
        
    func loadEntries(for tamagotchiId: String) {
        diaryService.fetchDiaryEntries(forTamagotchiId: tamagotchiId) { entries in
            self.diary = entries
        }
    }
    
    func addEntry(_ entry: DiaryEntry) {
        diaryService.addDiaryEntry(_entry: entry) { success in
            if success {
                print("Diary Entry added Successfully")
            } else {
                print("Failed to add Diary Entry")
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
