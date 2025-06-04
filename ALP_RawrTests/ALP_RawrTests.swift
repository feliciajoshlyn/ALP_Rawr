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
    var petHomeViewModel: PetHomeViewModel!
    var walkingViewModel: WalkingViewModel!
    var authViewModel: AuthViewModel!
    
    
    var defaultPet: PetModel = PetModel(
        name: "Default",
        hp: 50.0,
        hunger: 50.0,
        isHungry: false,
        bond: 0,
        lastFed: Date(),
        lastPetted: Date(),
        lastWalked: Date(),
        lastShower: Date(),
        lastChecked: Date(),
        currMood: "Happy",
        emotions: [
            "Happy":PetEmotionModel(
                name: "Happy",
                level: 50.0,
                limit: 40.0,
                priority: 1,
                icon: "happybadge"
            ),
            "Sad":PetEmotionModel(name: "Sad", level: 0.0, limit: 50.0, priority: 2, icon: "sadbadge"),
            "Angry":PetEmotionModel(name: "Angry", level: 0.0, limit: 70.0, priority: 3, icon: "angrybadge"),
            "Bored":PetEmotionModel(name: "Bored", level: 0.0, limit: 60.0, priority: 4, icon: "boredbadge"),
            "Fear":PetEmotionModel(name: "Fear", level: 0.0, limit: 80.0, priority: 5, icon: "fearbadge")
        ],
        userId: ""
    )
    
    let mockPetService = MockPetService()
    let mockWalkService =  MockWalkingService()
    let mockUserService = MockUserService()
    let mockAuthService = MockAuthService()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.diaryMockService = MockDiaryService()
        self.diaryViewModel = DiaryViewModel(diaryService: self.diaryMockService)
        //        let mockWCSession = MockWCSession()
        self.petHomeViewModel = PetHomeViewModel(petService: mockPetService)
        self.authViewModel = AuthViewModel(authService: mockAuthService)
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
    
    //tes fetchdiary
    func testFetchDiary() async {
        let entry = DiaryEntry(id: "testId", data: [
            "userId": "123",
            "title": "Test Title",
            "text": "Test Entry",
            "createdAt": Date()
        ])
        diaryMockService.mockUser = MyUser(uid: "testId", username: "testUsername", friends: ["testFriendId"])
        //put it in the entry
        diaryMockService.mockDiaryEntries = [entry]
        diaryMockService.mockFriends = ["testId"]
        //tes dari sisi friendId ada or no
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
    
    func testFetchPet(){
        let expectation = self.expectation(description: "Fetching pet")
        
        //Waktu blm fetch, masih pakai PetModel() aja itu nama defaultnya ""
        XCTAssertEqual(self.petHomeViewModel.pet.name, "")
        
        // Diisi currentUserId nya biar functionnya gk kestop di error handling itu
        self.petHomeViewModel.fetchPetData(currentUserId: "00")
        
        // Wait a moment for the async fetch to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.petHomeViewModel.pet.name, "MockPet")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testApplyInteraction(){
        //assign default pet dulu
        self.petHomeViewModel.pet = defaultPet
        
        //Get the last Petted
        let oldDate = self.petHomeViewModel.pet.lastPetted
        
        //Coba di-pet
        self.petHomeViewModel.applyInteraction(.petting)
        
        //Cek lastPetted nya sudah berubah
        XCTAssertNotEqual(self.petHomeViewModel.pet.lastPetted, oldDate)
        
        //Cek level happynya hrsnya sudah di atas 50
        XCTAssertGreaterThan(self.petHomeViewModel.pet.emotions["Happy"]!.level, 50)
    }
    
    func testCheckCurrEmotion(){
        //assign default pet lagi
        self.petHomeViewModel.pet = defaultPet
        self.petHomeViewModel.checkCurrEmotion()
        
        //defaultPet should be happy
        XCTAssertEqual(self.petHomeViewModel.currEmotion, "Happy")
        
        //change emotion levels to apply Sad
        self.petHomeViewModel.pet.emotions["Happy"]!.level = 0
        self.petHomeViewModel.pet.emotions["Sad"]!.level = 100
        
        //Now the pet should be sad
        self.petHomeViewModel.checkCurrEmotion()
        XCTAssertEqual(self.petHomeViewModel.currEmotion, "Sad")
    }
    
    func testUpdatePetStatusPeriodically() {
        // Step 1: Create a Pet with specific timestamps in the past
        let now = Date()
        
        let pastChecked = now.addingTimeInterval(-180) // 3 minutes ago
        let lastFed = now.addingTimeInterval(-9 * 3600) // 9 hours ago
        let lastPetted = now.addingTimeInterval(-13 * 3600) // 13 hours ago
        let lastWalked = now.addingTimeInterval(-17 * 3600) // 17 hours ago
        let lastShower = now.addingTimeInterval(-49 * 3600) // 31 hours ago
        
        self.petHomeViewModel.pet = defaultPet
        self.petHomeViewModel.pet.hp = 90.0
        self.petHomeViewModel.pet.hunger = 20.0
        self.petHomeViewModel.pet.emotions["Happy"]!.level = 50.0
        self.petHomeViewModel.pet.emotions["Sad"]!.level = 20.0
        self.petHomeViewModel.pet.emotions["Angry"]!.level = 10.0
        self.petHomeViewModel.pet.emotions["Bored"]!.level = 5.0
        self.petHomeViewModel.pet.emotions["Fear"]!.level = 2.0
        self.petHomeViewModel.pet.lastChecked = pastChecked
        self.petHomeViewModel.pet.lastFed = lastFed
        self.petHomeViewModel.pet.lastPetted = lastPetted
        self.petHomeViewModel.pet.lastWalked = lastWalked
        self.petHomeViewModel.pet.lastShower = lastShower
        
        // Step 3: Run the method
        self.petHomeViewModel.updatePetStatusPeriodically()
        
        // Step 4: Assert the updated values
        // Hunger should decrease: 3 minutes = -1 hunger
        XCTAssertEqual(self.petHomeViewModel.pet.hunger, 19, accuracy: 0.1)
        
        // Because it's hungry (< 50), HP should not increase
        // HP should decrease slightly (due to hunger under 15? Not in this case)
        
        // HP penalty due to neglect: all 4 triggers => 4 points
        // hpDecrease = (3 * 4) / 15 = 0.8
        XCTAssertEqual(self.petHomeViewModel.pet.hp, 89.2, accuracy: 0.1)
        
        // Emotions:
        // Sad: > 6 hrs since pet => increase
        XCTAssertTrue((self.petHomeViewModel.pet.emotions["Sad"]?.level ?? 0) > 20)
        
        // Angry: hunger < 50 => increase
        XCTAssertTrue((self.petHomeViewModel.pet.emotions["Angry"]?.level ?? 0) > 10)
        
        // Bored: sinceWalked > 8 => increase
        XCTAssertTrue((self.petHomeViewModel.pet.emotions["Bored"]?.level ?? 0) > 5)
        
        // Fear: sinceShower > 48 => increase
        XCTAssertTrue((self.petHomeViewModel.pet.emotions["Fear"]?.level ?? 0) > 2)
        
        // Happy: average of hunger (49) and hp (89.2) = 69.1 => no change (between 40 and 70)
        XCTAssertEqual(self.petHomeViewModel.pet.emotions["Happy"]?.level ?? 0, 50, accuracy: 0.2)
    }
    
    func testSavePet(){
        let expectation = self.expectation(description: "Saving pet")
        
        //Sebelum ada yang disave mockSave nya nil
        XCTAssertNil(self.mockPetService.mockPetSave)
        
        //Diisi default pet yang namanya "Default"
        self.petHomeViewModel.pet = defaultPet
        self.petHomeViewModel.savePet(currentUserId: "00")
        
        // Wait a moment for the async fetch to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.mockPetService.mockPetSave!.name, self.petHomeViewModel.pet.name)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testRefetchPetData(){
        let expectation = self.expectation(description: "Refetching Pet")
        
        //Awalnya kalau blm diisi masih pakai default value, nama petnya itu ""
        XCTAssertEqual(self.petHomeViewModel.pet.name, "")
        
        self.petHomeViewModel.refetchPetData(currentUserId: "00")
        
        // Wait a moment for the async fetch to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.petHomeViewModel.pet.name, "MockPet")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testResetViewModel(){
        //Pet datanya diisi dulu dan hasFetchData skrng jadi true
        self.petHomeViewModel.fetchPetData(currentUserId: "00")
        
        XCTAssertTrue(self.petHomeViewModel.hasFetchData)
        
        //Kalau direset nanti hrsnya hasFetchData jadi false lagi
        self.petHomeViewModel.resetViewModel()
        XCTAssertFalse(self.petHomeViewModel.hasFetchData)
    }
    
//    func testCreateWalking() async{
//        let walk = WalkingModel(
//            id: "1",
//            userId: "123",
//            startTime: Date(),
//            endTime: Date().addingTimeInterval(3600),
//            duration: 3600,
//            distance: 5.0,
//            averageSpeed: 5.0,
//            notes: "Mock walking session"
//        )
//        walkingViewModel.createWalking(walk: walk)
//        
//        XCTAssertEqual(mockWalkService.mockWalkingCount.count, 1)
//    }
    
    func testSignUpSuccess() async {
       
            authViewModel.myUser.email = "test@example.com"
            authViewModel.myUser.password = "password123"
            authViewModel.myUser.username = "testuser"
            authViewModel.petName = "TestPet"
        
        mockAuthService.shouldReturnSuccess = true
        
        await authViewModel.signUp()
        
        XCTAssertTrue(mockAuthService.signUpCalled)
        XCTAssertFalse(authViewModel.falseCredential)
        XCTAssertTrue(authViewModel.isSigningIn)
        XCTAssertEqual(authViewModel.myUser.username, "testuser")
        XCTAssertEqual(authViewModel.myUser.email, "test@example.com")
        XCTAssertNotEqual(authViewModel.myUser.uid, "")
    }

    func testSignUpFailure() async {
            authViewModel.myUser.email = "test@example.com"
            authViewModel.myUser.password = "password123"
            authViewModel.myUser.username = "testuser"
            authViewModel.petName = "TestPet"
        
        mockAuthService.shouldReturnSuccess = false
        
        await authViewModel.signUp()
        
        XCTAssertTrue(mockAuthService.signUpCalled)
        XCTAssertTrue(authViewModel.falseCredential)
        XCTAssertFalse(authViewModel.isSigningIn)
    }

    func testSignUpWithoutPetName() async {
            authViewModel.myUser.email = "test@example.com"
            authViewModel.myUser.password = "password123"
            authViewModel.myUser.username = "testuser"
            authViewModel.petName = ""
        
        mockAuthService.shouldReturnSuccess = true
        
        await authViewModel.signUp()
        
        XCTAssertFalse(mockAuthService.signUpCalled)
        XCTAssertTrue(authViewModel.falseCredential)
        XCTAssertFalse(authViewModel.isSigningIn)
    }

    func testSignInSuccess() async {
        mockAuthService.addMockUser(email: "test@example.com", password: "password123", username: "testuser")
        
            authViewModel.myUser.email = "test@example.com"
            authViewModel.myUser.password = "password123"
            authViewModel.myUser.username = "testuser"
        
        mockAuthService.shouldReturnSuccess = true
        
        await authViewModel.signIn()
        
        XCTAssertTrue(mockAuthService.signInCalled)
        XCTAssertFalse(authViewModel.falseCredential)
        XCTAssertTrue(authViewModel.isSigningIn)
        XCTAssertEqual(authViewModel.myUser.username, "testuser")
        XCTAssertEqual(authViewModel.myUser.email, "test@example.com")
    }

    func testSignInFailure() async {
            authViewModel.myUser.email = "test@example.com"
            authViewModel.myUser.password = "wrongpassword"
            authViewModel.myUser.username = "testuser"
        
        mockAuthService.shouldReturnSuccess = false
        
        await authViewModel.signIn()
        
        XCTAssertTrue(mockAuthService.signInCalled)
        XCTAssertTrue(authViewModel.falseCredential)
        XCTAssertFalse(authViewModel.isSigningIn)
    }

    func testSignOut() {
        // SignOut is sync, so just update state inside MainActor.run for safety
        Task {
                authViewModel.myUser = MyUser(uid: "123", username: "testuser", email: "test@example.com", password: "", friends: [])
                authViewModel.isSigningIn = true
            authViewModel.signOut()
            
            XCTAssertTrue(mockUserService.signOutCalled)
            XCTAssertFalse(authViewModel.isSigningIn)
            XCTAssertEqual(authViewModel.myUser.uid, "")
            XCTAssertEqual(authViewModel.myUser.username, "")
            XCTAssertEqual(authViewModel.myUser.email, "")
        }
    }



    // MARK: - MockAuthService Direct Tests

    func testMockAuthServiceSignUpDirect() async {
        // Given
        let email = "direct@example.com"
        let password = "directpassword"
        let username = "directuser"
        let petName = "DirectPet"
        
        mockAuthService.shouldReturnSuccess = true
        
        do {
            // When
            let user = try await mockAuthService.signUp(email: email, password: password, username: username, petName: petName)
            
            // Then
            XCTAssertTrue(mockAuthService.signUpCalled)
            XCTAssertEqual(user.email, email)
            XCTAssertEqual(user.username, username)
            XCTAssertNotEqual(user.uid, "")
            XCTAssertEqual(user.password, "") // Should be empty for security
        } catch {
            XCTFail("SignUp should not throw error: \(error)")
        }
    }

    func testMockAuthServiceSignInDirect() async {
        // Given
        let email = "signin@example.com"
        let password = "signinpassword"
        let username = "signinuser"
        
        // First add user to mock service
        mockAuthService.addMockUser(email: email, password: password, username: username)
        mockAuthService.shouldReturnSuccess = true
        
        do {
            // When
            let user = try await mockAuthService.signIn(email: email, password: password, username: username)
            
            // Then
            XCTAssertTrue(mockAuthService.signInCalled)
            XCTAssertEqual(user.email, email)
            XCTAssertEqual(user.username, username)
            XCTAssertNotEqual(user.uid, "")
        } catch {
            XCTFail("SignIn should not throw error: \(error)")
        }
    }

    func testMockAuthServiceSignInWithNonExistentUser() async {
        // Given
        let email = "nonexistent@example.com"
        let password = "password"
        let username = "nonexistentuser"
        
        mockAuthService.shouldReturnSuccess = true
        mockAuthService.clearMockUsers() // Ensure no users exist
        
        do {
            // When
            let user = try await mockAuthService.signIn(email: email, password: password, username: username)
            
            // Then - Should create mock user for testing
            XCTAssertTrue(mockAuthService.signInCalled)
            XCTAssertEqual(user.email, email)
            XCTAssertEqual(user.username, username)
            XCTAssertNotEqual(user.uid, "")
        } catch {
            XCTFail("SignIn should not throw error for mock service: \(error)")
        }
    }

    // MARK: - MockUserService Tests

    func testCreateUserDocument() async {
        // Given
        let userId = "testUserId"
        let email = "test@example.com"
        let username = "testuser"
        
        do {
            // When
            try await mockUserService.createUserDocument(userId: userId, email: email, username: username)
            
            // Then
            XCTAssertTrue(mockUserService.createUserDocumentCalled)
            XCTAssertNotNil(mockUserService.mockUser)
            XCTAssertEqual(mockUserService.mockUser?.uid, userId)
            XCTAssertEqual(mockUserService.mockUser?.username, username)
            XCTAssertEqual(mockUserService.mockUser?.email, email)
        } catch {
            XCTFail("createUserDocument should not throw error: \(error)")
        }
    }

    func testUserServiceSignOut() {
        do {
            // When
            try mockUserService.signOut()
            
            // Then
            XCTAssertTrue(mockUserService.signOutCalled)
        } catch {
            XCTFail("signOut should not throw error: \(error)")
        }
    }
    
    
}
