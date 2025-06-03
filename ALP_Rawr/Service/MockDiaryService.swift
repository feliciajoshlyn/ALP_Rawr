//
//  MockDiaryService.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 01/06/25.
//

import Foundation

class MockDiaryService: DiaryServiceProtocol {
    var shouldReturnSuccess = true
    var mockDiaryEntries: [DiaryEntry] = []
    var mockFriends: [String] = []
    var mockUser: MyUser?
    
    func addDiaryEntry(entry: DiaryEntry, completion: @escaping (Bool) -> Void) {
        if shouldReturnSuccess {
            mockDiaryEntries.append(entry)
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func fetchFriends(userId: String, completion: @escaping ([String]) -> Void) {
        completion(mockUser?.friends ?? [""])
    }
    
    func fetchDiaryWithFriends(userId: String, friends: [String], completion: @escaping ([DiaryEntry]) -> Void) {
        let combinedIds = friends + [userId]
        let filtered = mockDiaryEntries.filter { combinedIds.contains($0.userId) }
        completion(filtered)
    }
    
    func searchUser(byUID: String, completion: @escaping (MyUser?) -> Void) {
        if mockUser?.uid == byUID {
            completion(mockUser)
        } else {
            completion(nil)
        }
    }
    
    func addMutualFriend(currentUserId: String, friendId: String, completion: @escaping (Bool) -> Void) {
        if shouldReturnSuccess {
            mockUser?.friends.append(friendId)
            mockFriends.append(currentUserId)
            completion(true)
        } else {
            completion(false)
        }
    }
    
    
}
