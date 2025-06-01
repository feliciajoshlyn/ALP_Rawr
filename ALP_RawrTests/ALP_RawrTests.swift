//
//  ALP_RawrTests.swift
//  ALP_RawrTests
//
//  Created by student on 16/05/25.
//

import XCTest
@testable import ALP_Rawr

final class ALP_RawrTests: XCTestCase {
    var diaryMockService : MockDiaryService!
    var diaryViewModel : DiaryViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.diaryMockService = MockDiaryService()
        self.diaryViewModel = DiaryViewModel(diaryService: self.diaryMockService)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.diaryMockService = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAddDiaryEntry() async {
        let entry = DiaryEntry(id: "testId", data: [
            "userId": "123",
            "title": "Test Title",
            "text": "Test Entry",
            "createdAt": Date()
        ])
        diaryViewModel.addEntry(entry)
        
        XCTAssertEqual(diaryMockService.mockDiaryEntries.count, 1)
    }

    
    func testFetchDiary() async {
        let entry = DiaryEntry(id: "testId", data: [
            "userId": "123",
            "title": "Test Title",
            "text": "Test Entry",
            "createdAt": Date()
        ])
        diaryMockService.mockDiaryEntries = [entry]
        diaryMockService.mockFriends = ["testFriendId"]
        diaryViewModel.loadEntries(for: "testFriendId")
        XCTAssertTrue(diaryMockService.mockDiaryEntries.count > 0)
        XCTAssertEqual(diaryMockService.mockDiaryEntries.first?.id, "testId")
    }
    
    func testSearchFriend() async {
        let user = MyUser(uid: "testId", username: "testUsername")
        diaryMockService.mockUser = user
        diaryViewModel.searchFriend(by: "testId")
        
        XCTAssertEqual(diaryMockService.mockUser?.username, user.username)
    }
    
    func testAddFriend() async {
        diaryMockService.mockUser = MyUser(uid: "testId", username: "testUsername")
        _ = MyUser(uid: "testId2", username: "testUsername2")
        diaryViewModel.addMutualFriend(from: "testId", to: "testId2")
        
        XCTAssertEqual(diaryMockService.mockUser?.friends, ["testId2"])
        XCTAssertEqual(diaryMockService.mockFriends, ["testId"])
    }
    
    func testFetchFriends() async {
        diaryMockService.mockUser = MyUser(uid: "testId", username: "testUsername")
        diaryMockService.mockUser?.friends = ["testId3", "testId2"]
        diaryViewModel.fetchCurrentUserFriends(currentUserId: "testId")
        
        XCTAssertEqual(diaryMockService.mockUser?.friends, ["testId3", "testId2"])
    }
}

