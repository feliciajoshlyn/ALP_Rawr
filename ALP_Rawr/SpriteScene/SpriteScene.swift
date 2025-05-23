//
//  SpriteScene.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import SpriteKit
import Combine

class SpriteScene: SKScene {
    private var spriteNode: SKSpriteNode!
    private var spriteModel = SpriteModel(
        facingDirection: .right,
        movementState: .idle,
        position: .zero,
        walkFrame: 1,
        frameTimer: 0.25
    )
    
    private var walkAnimationTimer: TimeInterval = 0
    private var isWalking = false
    private var targetX: CGFloat = 0
    
    var onPet: (() -> Void)?

    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupSprite()
        chooseNextAction()
    }

    private func setupSprite() {
        spriteModel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        spriteNode = SKSpriteNode(imageNamed: "dog_inplace_right")
        spriteNode.position = spriteModel.position
        spriteNode.size = CGSize(width: 100, height: 100)
        addChild(spriteNode)
    }

    override func update(_ currentTime: TimeInterval) {
        updateSpriteMovement()
        updateSpriteAnimation(deltaTime: 1/60.0)
    }

    private func updateSpriteMovement() {
        guard spriteModel.movementState == .walking else { return }

        let dx = targetX - spriteModel.position.x
        if abs(dx) < 1 {
            stopWalking()
            return
        }

        let step: CGFloat = dx > 0 ? 1.5 : -1.5
        spriteModel.position.x += step
        spriteNode.position.x = spriteModel.position.x

        spriteModel.facingDirection = dx > 0 ? .right : .left
    }

    private func updateSpriteAnimation(deltaTime: TimeInterval) {
        spriteModel.frameTimer -= deltaTime

        guard spriteModel.movementState == .walking else {
            updateIdleTexture()
            return
        }

        if spriteModel.frameTimer <= 0 {
            // Switch walk frame
            spriteModel.walkFrame = (spriteModel.walkFrame == 1) ? 2 : 1
            spriteModel.frameTimer = 0.25
        }

        let frameName = "dog_walk\(spriteModel.walkFrame)_\(spriteModel.facingDirection == .right ? "right" : "left")"
        spriteNode.texture = SKTexture(imageNamed: frameName)
    }

    private func updateIdleTexture() {
        let idleName = "dog_inplace_\(spriteModel.facingDirection == .right ? "right" : "left")"
        spriteNode.texture = SKTexture(imageNamed: idleName)
    }

    private func chooseNextAction() {
        let delay = TimeInterval.random(in: 2.0...4.0)
        run(.wait(forDuration: delay)) { [weak self] in
            self?.startRandomWalk()
        }
    }

    private func startRandomWalk() {
        let newTarget = CGFloat.random(in: 50...(size.width - 50))
        targetX = newTarget
        spriteModel.movementState = .walking
        spriteModel.facingDirection = newTarget > spriteModel.position.x ? .right : .left
        spriteModel.frameTimer = 0.25
        spriteModel.walkFrame = 1
    }

    private func stopWalking() {
        spriteModel.movementState = .idle
        updateIdleTexture()
        chooseNextAction()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if spriteNode.contains(location) {
            onPet?()
        }
    }
}
