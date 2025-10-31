import SpriteKit

class Block {
    let sprite: SKSpriteNode

    init(position: CGPoint, size: CGFloat) {
        // Create block sprite (orange rectangle)
        sprite = SKSpriteNode(color: UIColor(red: 1.0, green: 153.0/255.0, blue: 0.0, alpha: 1.0),
                             size: CGSize(width: size, height: size))
        sprite.position = position
        sprite.zPosition = 5

        // Setup physics
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.block
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.playerLaser | PhysicsCategory.alienLaser | PhysicsCategory.alien
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
}
