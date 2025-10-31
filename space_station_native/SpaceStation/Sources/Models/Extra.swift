import SpriteKit

class Extra {
    let sprite: SKSpriteNode
    private let speed: CGFloat

    init(side: String, screenWidth: CGFloat) {
        let texture = SKTexture(imageNamed: "extra")

        if side == "right" {
            sprite = SKSpriteNode(texture: texture)
            sprite.position = CGPoint(x: screenWidth + 50, y: 80)
            speed = -4.0
        } else {
            sprite = SKSpriteNode(texture: texture)
            sprite.position = CGPoint(x: -50, y: 80)
            speed = 4.0
        }

        sprite.zPosition = 5

        // Setup physics
        sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.extra
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.playerLaser
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    func update() {
        sprite.position.x += speed
    }
}
