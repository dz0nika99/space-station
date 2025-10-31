import SpriteKit

class Laser {
    enum Direction {
        case up, down
    }

    let sprite: SKSpriteNode
    private let speed: CGFloat
    private let direction: Direction
    private let screenHeight: CGFloat
    var isActive = true

    init(position: CGPoint, speed: CGFloat, direction: Direction, screenHeight: CGFloat) {
        self.speed = speed
        self.direction = direction
        self.screenHeight = screenHeight

        // Create laser sprite (white rectangle)
        sprite = SKSpriteNode(color: .white, size: CGSize(width: 4, height: 20))
        sprite.position = position
        sprite.zPosition = 5

        // Setup physics based on direction
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.isDynamic = true

        if direction == .up {
            // Player laser
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.playerLaser
            sprite.physicsBody?.contactTestBitMask = PhysicsCategory.alien | PhysicsCategory.block | PhysicsCategory.extra
        } else {
            // Alien laser
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.alienLaser
            sprite.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.block
        }

        sprite.physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    func update() -> Bool {
        // Move laser
        let moveSpeed = speed * (direction == .up ? -1 : 1) // Negative for up, positive for down
        sprite.position.y += moveSpeed

        // Check if laser is out of bounds
        if sprite.position.y < -50 || sprite.position.y > screenHeight + 50 {
            isActive = false
            return false
        }

        return true
    }
}
