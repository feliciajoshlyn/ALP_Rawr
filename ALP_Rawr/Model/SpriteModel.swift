//
//  SpriteModel.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import Foundation

struct SpriteModel {
    var facingDirection: FacingDirection
    var movementState: MovementState
    var position: CGPoint
    var walkFrame: Int // 1 or 2 for walk animations
    var frameTimer: Double // Time before switching animation frames
}
