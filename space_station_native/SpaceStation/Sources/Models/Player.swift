import SpriteKit

class Player {
    let sprite: SKSpriteNode
    private let speed: CGFloat = 5.0
    private let maxXConstraint: CGFloat
    private var ready = true
    private var laserTime: TimeInterval = 0
    private let laserCooldown: TimeInterval = 700 // milliseconds, like Pygame

    // Bobbing animation properties
    private let bobHeight: CGFloat = 1.0
    private let bobSpeed: CGFloat = 0.1
    private var bobOffset: CGFloat = 0.0
    private let baseY: CGFloat

    // Movement state
    private var movingLeft = false
    private var movingRight = false

    init(position: CGPoint, screenWidth: CGFloat) {
        self.maxXConstraint = screenWidth

        // Create player sprite
        let texture = SKTexture(imageNamed: "spaceship")
        sprite = SKSpriteNode(texture: texture)
        sprite.position = position
        sprite.zPosition = 10
        baseY = position.y

        // Setup physics
        sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.player
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.alienLaser | PhysicsCategory.alien
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    func update() {
        // Handle movement
        if movingLeft {
            sprite.position.x -= speed
        } else if movingRight {
            sprite.position.x += speed
        }

        // Apply constraints
        if sprite.position.x - sprite.size.width / 2 < 0 {
            sprite.position.x = sprite.size.width / 2
        } else if sprite.position.x + sprite.size.width / 2 > maxXConstraint {
            sprite.position.x = maxXConstraint - sprite.size.width / 2
        }

        // Update laser cooldown (in milliseconds like Pygame)
        if !ready {
            let currentTime = Date.timeIntervalSinceReferenceDate * 1000
            if currentTime - laserTime >= laserCooldown {
                ready = true
            }
        }

        // Apply bobbing effect
        bobOffset += bobSpeed
        let bobY = baseY + sin(bobOffset) * bobHeight
        sprite.position.y = bobY
    }

    func moveLeft() {
        movingLeft = true
        movingRight = false
    }

    func moveRight() {
        movingLeft = false
        movingRight = true
    }

    func stopMoving() {
        movingLeft = false
        movingRight = false
    }

    func shootLaser() -> Laser? {
        guard ready else { return nil }

        let laserPosition = CGPoint(x: sprite.position.x, y: sprite.position.y + sprite.size.height / 2)
        let laser = Laser(position: laserPosition, speed: -8, direction: .up, screenHeight: 0)
        laser.sprite.zPosition = 5

        ready = false
        laserTime = Date.timeIntervalSinceReferenceDate * 1000 // milliseconds like Pygame

        return laser
    }
}
