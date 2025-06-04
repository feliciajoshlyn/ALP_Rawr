//
//  MockWalkingService.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 04/06/25.
//

import Foundation

class MockWalkingService: WalkingService {
    var createWalkingCalled = false
    var mockWalkingCount: [WalkingModel] = []

    var mockWalkingToReturn: WalkingModel? = WalkingModel(
        id: "1",
        userId: "123",
        startTime: Date(),
        endTime: Date().addingTimeInterval(3600),
        duration: 3600,
        distance: 5.0,
        averageSpeed: 5.0,
        notes: "Mock walking session"
    )
    
    var shouldCreateSucceed: Bool = true
    
    func createWalking(walk: WalkingModel, completion: @escaping (Bool) -> Void) {
        createWalkingCalled = true
        mockWalkingCount.append(walk)
        completion(shouldCreateSucceed)
    }

}
