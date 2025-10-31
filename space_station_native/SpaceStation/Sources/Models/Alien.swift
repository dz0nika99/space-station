import SpriteKit

class Alien {
    enum AlienColor: String {
        case red, green, yellow

        var pointValue: Int {
            switch self {
            case .red: return 100
            case .green: return 300
            case .yellow: return 500
            }
        }
    }

    let sprite: SKSpriteNode
    let pointValue: Int
    private let color: AlienColor

    // Bobbing animation properties
    private let bobHeight: CGFloat = 1.0
    private let bobSpeed: CGFloat = 0.1
    private var bobOffset: CGFloat = 0.0

    init(color: AlienColor, position: CGPoint) {
        self.color = color
        self.pointValue = color.pointValue

        // Create alien sprite
        let texture = SKTexture(imageNamed: color.rawValue)
        sprite = SKSpriteNode(texture: texture)
        sprite.position = position
        sprite.zPosition = 5

        // Setup physics
        sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.alien
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.playerLaser | PhysicsCategory.player | PhysicsCategory.block
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    func update(direction: CGFloat) {
        sprite.position.x += direction

        // Apply bobbing effect
        bobOffset += bobSpeed
        let bobY = sprite.position.y + sin(bobOffset) * bobHeight
        sprite.position.y = bobY
    }
}
