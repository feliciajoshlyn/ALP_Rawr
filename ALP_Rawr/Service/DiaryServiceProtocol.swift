//
//  DiaryServiceProtocol.swift
//  ALP_Rawr
//
//  Created by Gerald Gavin Lienardi on 01/06/25.
//

import Foundation

protocol DiaryServiceProtocol {
    func addDiaryEntry(entry: DiaryEntry, completion: @escaping (Bool) -> Void)
    func fetchFriends(userId: String, completion: @escaping ([String]) -> Void)
    func fetchDiaryWithFriends(userId: String, friends: [String], completion: @escaping ([DiaryEntry]) -> Void)
    func searchUser(byUID: String, completion: @escaping (MyUser?) -> Void)
    func addMutualFriend(currentUserId: String, friendId: String, completion: @escaping (Bool) -> Void)
}
