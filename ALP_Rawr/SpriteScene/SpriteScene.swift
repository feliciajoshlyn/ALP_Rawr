//
//  SpriteScene.swift
//  ALP_Rawr
//
//  Created by student on 16/05/25.
//

import SpriteKit
import Combine
import SwiftUI

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
    
    // Sabun
    private var soapNode: SKSpriteNode!
    private var isDraggingSoap = false
    private var isShowering = false
    private var isSoapReturning = false
    private var soapOriginalPosition: CGPoint = .zero
    
    // Makanan
    private var foodNode: SKSpriteNode!
    private var isDraggingFood = false
    private var foodOriginalPosition: CGPoint = .zero
    private var hasFed = false
    
    var onPet: (() -> Void)?
    var onShower: (() -> Void)?
    var onFeed: (() -> Void)?

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.964, green: 0.969, blue: 0.969, alpha: 1)
        setupSprite()
        chooseNextAction()
        
        //Initialize soap node
        setupSoap()
        setupBubbles()
        
        setupFood()
    }

    private func setupSprite() {
        spriteModel.position = CGPoint(x: size.width / 2, y: size.height / 1.5)
        spriteNode = SKSpriteNode(imageNamed: "dog_inplace_right")
        spriteNode.position = spriteModel.position
        
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let width = isIpad ? 300 : 150
        let height = isIpad ? 300 : 150
        
        spriteNode.size = CGSize(width: width, height: height)
        addChild(spriteNode)
    }
    
    private func setupSoap(){
        let texture = SKTexture(imageNamed: "soap")
        let aspectRatio = texture.size().width / texture.size().height
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        
        let desiredHeight: CGFloat = isIpad ? 110 : 55
        let calculatedWidth = desiredHeight * aspectRatio
        
        soapNode = SKSpriteNode(imageNamed: "soap")
        soapNode.position = CGPoint(x: size.width / 4, y: 100)
        self.soapOriginalPosition = soapNode.position
        soapNode.size = CGSize(width: calculatedWidth, height: desiredHeight)
        soapNode.zPosition = 10 // Supaya bisa didrag di atas anjingnya
        addChild(soapNode)
    }
    
    private func setupBubbles(){
        if let bubbles = SKEmitterNode(fileNamed: "Bubbles.sks") {
            bubbles.name = "bubbles"
            bubbles.isHidden = true
            bubbles.zPosition = 5
            bubbles.targetNode = self

            // Attach the emitter to the soapNode so it moves with it
            bubbles.particleBirthRate = 0 // start with no particles
            soapNode.addChild(bubbles)
        }
    }
    
    private func setupFood(){
        let texture = SKTexture(imageNamed: "kibble")
        let aspectRatio = texture.size().width / texture.size().height
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        
        let desiredHeight: CGFloat = isIpad ? 110 : 55
        let calculatedWidth = desiredHeight * aspectRatio
        
        foodNode = SKSpriteNode(imageNamed: "kibble")
        foodNode.position = CGPoint(x: 3*(size.width / 4), y: 95)
        self.foodOriginalPosition = foodNode.position
        foodNode.size = CGSize(width: calculatedWidth, height: desiredHeight)
        foodNode.zPosition = 10 // Supaya bisa didrag di atas anjingnya
        addChild(foodNode)
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
        
        // Always reset both drag states first
        isDraggingSoap = false
        isDraggingFood = false
        
        // Check draggable items first, but only if they're not overlapping the dog
        if foodNode.contains(location) && !foodNode.frame.intersects(spriteNode.frame) {
            isDraggingFood = true
        } else if soapNode.contains(location) && !isSoapReturning && !soapNode.frame.intersects(spriteNode.frame) {
            isDraggingSoap = true
        } else if spriteNode.contains(location) {
            // Only pet if no items are being dragged and no items are overlapping
            onPet?()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isDraggingSoap {
            soapNode.position = location
            checkSoapOverDog()
        } else if isDraggingFood {
            foodNode.position = location
            checkFoodOverDog()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDraggingSoap {
            isDraggingSoap = false
            stopShowerEffect()
            isSoapReturning = true
            let moveBack = SKAction.move(to: soapOriginalPosition, duration: 0.2)
            moveBack.timingMode = .easeOut
            soapNode.run(moveBack) { [weak self] in
                self?.isSoapReturning = false
            }
        }

        if isDraggingFood {
            isDraggingFood = false
            let moveBack = SKAction.move(to: foodOriginalPosition, duration: 0.2)
            moveBack.timingMode = .easeOut
            foodNode.run(moveBack)
        }
    }
    
    private func checkSoapOverDog() {
        let isOverlapping = soapNode.frame.intersects(spriteNode.frame)

        if isOverlapping && !isShowering {
            startShowerEffect()
            onShower?()
        } else if !isOverlapping && isShowering {
            stopShowerEffect()
        }
    }
    
    private func checkFoodOverDog(){
        let isOverlapping = foodNode.frame.intersects(spriteNode.frame)

        if isOverlapping && !hasFed {
            hasFed = true
            onFeed?()

            // Reset after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.hasFed = false
            }
        }
    }
    
    private func startShowerEffect() {
        guard let bubbles = soapNode.childNode(withName: "bubbles") as? SKEmitterNode else { return }

        bubbles.targetNode = self
        bubbles.isHidden = false
//        bubbles.resetSimulation()
        bubbles.particleBirthRate = 5 // or your desired rate

        isShowering = true
    }

    private func stopShowerEffect() {
        guard let bubbles = soapNode.childNode(withName: "bubbles") as? SKEmitterNode else { return }

        bubbles.particleBirthRate = 0

        run(.wait(forDuration: 0.05)) {
            bubbles.isHidden = true
        }

        isShowering = false
    }
}
