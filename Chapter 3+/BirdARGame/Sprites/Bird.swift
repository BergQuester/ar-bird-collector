//
//  Bird.swift
//  LyndaARGame
//
//  Created by Brian Advent on 24.05.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import SpriteKit
import GameplayKit

extension Notification.Name {
    static let birdDidFly = Notification.Name("Bird.birdDidFly")
}

class Bird: SKSpriteNode {
    var mainSprite = SKSpriteNode()

    func setup() {

        // setup initial image
        mainSprite = SKSpriteNode(imageNamed: "bird1")
        self.addChild(mainSprite)

        // Load animation texture atlas
        let textureAtlas = SKTextureAtlas(named: "bird")
        let frames = ["sprite_0", "sprite_1", "sprite_2", "sprite_3", "sprite_4", "sprite_5", "sprite_6"].map { textureAtlas.textureNamed($0)}

        // Create animation
        let atlasAnimation = SKAction.animate(with: frames, timePerFrame: 1/2, resize: true, restore: false)

        let animationAction = SKAction.repeatForever(atlasAnimation)

        mainSprite.run(animationAction)

        // randomly face left or right
        let left = GKRandomSource.sharedRandom().nextBool()
        if left {
            mainSprite.xScale = -1
        }

        // fade after a random amount of time
        let duration = randomNumber(lowerBound: 15, upperBound: 20)

        let fade = SKAction.fadeOut(withDuration: TimeInterval(duration))
        let removeBird = SKAction.run {
            NotificationCenter.default.post(name: Notification.Name.birdDidFly, object: nil)
            self.removeFromParent()
        }

        let flySequence = SKAction.sequence([fade, removeBird])

        mainSprite.run(flySequence)
    }
}


