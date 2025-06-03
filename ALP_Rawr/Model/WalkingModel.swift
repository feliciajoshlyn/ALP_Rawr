//
//  Walking.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 30/05/25.
//

import Foundation

struct WalkingModel: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String = ""
    var startTime: Date = Date()
    var endTime: Date = Date()
    var duration: TimeInterval = 0
    var distance: Double = 0
    var averageSpeed: Double? = nil
    var notes: String? = nil
}
