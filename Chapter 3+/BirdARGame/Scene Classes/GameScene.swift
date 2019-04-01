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
    var timerLabel:SKLabelNode!
    var counterLabel:SKLabelNode!

    static var gameState: GameState = .none

    override func didMove(to view: SKView) {
        let waitAction = SKAction.wait(forDuration: 0.5)
        let spawnAction = SKAction.run {
            self.performInitialSpawn()
        }

        self.run(SKAction.sequence([waitAction, spawnAction]))
    }

    func performInitialSpawn() {
        GameScene.gameState = .spwanBirds

        for _ in 1...numberOfBirds {
            spawnBird()
        }
    }

    func spawnBird() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }

        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4

            translation.columns.3.x = randomPosition(lowerBound: -0.2, upperBound: 0.2)
            translation.columns.3.y = randomPosition(lowerBound: -0.2, upperBound: 0.2)
            translation.columns.3.z = randomPosition(lowerBound: -0.5, upperBound: 0.2)

            let transform = simd_mul(currentFrame.camera.transform, translation)

            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}
