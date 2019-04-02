//
//  GameScene.swift
//  LyndaARGame
//
//  Created by Brian Advent on 22.05.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit



class GameScene: SKScene {
    
    var numberOfBirds = 10
    var timerLabel: SKLabelNode!
    var counterLabel: SKLabelNode!

    var remainingTime: Int = 30 {
        didSet {
            timerLabel.text = "\(remainingTime) sec"
        }
    }

    var score: Int = 0 {
        didSet {
            counterLabel.text = "\(score) Birds"
        }
    }

    static var gameState: GameState = .none

    func setupHUD() {
        timerLabel = self.childNode(withName: "timerLabel") as? SKLabelNode
        counterLabel = self.childNode(withName: "counterLabel") as? SKLabelNode

        timerLabel.position = CGPoint(x: (self.size.width / 2) - 70,
                                      y: (self.size.height / 2) - 90)

        counterLabel.position = CGPoint(x: -(self.size.width / 2) + 70,
                                      y: (self.size.height / 2) - 90)

        let wait = SKAction.wait(forDuration: 1)
        let action = SKAction.run {
            self.remainingTime -= 1
        }

        let timerAction = SKAction.sequence([wait, action])
        self.run(SKAction.repeatForever(timerAction))
    }

    func gameOver() {
        let reveal = SKTransition.crossFade(withDuration: 0.9)

        guard let sceneView = self.view as? ARSKView,
            let mainMenu = MainMenuScene(fileNamed: "MainMenuScene")else {
            return
        }

        sceneView.presentScene(mainMenu, transition: reveal)
    }

    override func didMove(to view: SKView) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GameScene.spawnBird),
                                               name: Notification.Name.birdDidFly, object: nil)
        setupHUD()

        let waitAction = SKAction.wait(forDuration: 0.5)
        let spawnAction = SKAction.run {
            self.performInitialSpawn()
        }

        self.run(SKAction.sequence([waitAction, spawnAction]))
    }

    override func update(_ currentTime: TimeInterval) {

        guard remainingTime != 0 else {
            self.removeAllActions()
            gameOver()
            return
        }

        guard let sceneView = self.view as? ARSKView else {
            return
        }

        detectCaptures(inSceneView: sceneView)
    }

    func detectCaptures(inSceneView sceneView: ARSKView) {

        guard let anchors = sceneView.session.currentFrame?.anchors,
            let cameraZ = sceneView.session.currentFrame?.camera.transform.columns.3.z else {
                return
        }

        // Grab relevant nodes
        let birdNodes = nodes(at: CGPoint.zero).compactMap { $0 as? Bird }
        let potentialCapturedBirds = anchors
            .filter { abs(cameraZ - $0.transform.columns.3.z) < 0.2 }
            .map { sceneView.node(for: $0) }

        // Compare each bird node to our potential capture, if matched, act
        for bird in birdNodes {
            for potentialCapture in potentialCapturedBirds{
                if bird == potentialCapture {
                    capture(bird: bird)
                }
            }
        }
    }

    func capture(bird: Bird) {
        bird.removeFromParent()
        spawnBird()
        score += 1
    }

    func performInitialSpawn() {
        GameScene.gameState = .spwanBirds

        for _ in 1...numberOfBirds {
            spawnBird()
        }
    }

    @objc func spawnBird() {
        guard let sceneView = self.view as? ARSKView,
            let currentFrame = sceneView.session.currentFrame else {
            return
        }

        var translation = matrix_identity_float4x4

        translation.columns.3.x = randomPosition(lowerBound: -1.5, upperBound: 1.5)
        translation.columns.3.y = randomPosition(lowerBound: -1.5, upperBound: 1.5)
        translation.columns.3.z = randomPosition(lowerBound: -2, upperBound: 2)

        let transform = simd_mul(currentFrame.camera.transform, translation)

        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
    }
}
