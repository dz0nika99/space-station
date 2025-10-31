import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    weak var gameDelegate: GameSceneDelegate?

    // Game state
    private var gameActive = false
    private var gameWon = false
    private var gameOver = false

    // Game objects
    private var player: Player!
    private var aliens: [Alien] = []
    private var alienLasers: [Laser] = []
    private var playerLasers: [Laser] = []
    private var blocks: [Block] = []
    private var extraAlien: Extra?

    // Game stats
    private var lives = 3
    private var score = 0

    // UI elements
    private var scoreLabel: SKLabelNode!
    private var livesIcons: [SKSpriteNode] = []
    private var homeScreenFrames: [SKTexture] = []
    private var currentFrameIndex = 0
    private var background: SKSpriteNode!

    // Audio
    private var playerLaserSound: AVAudioPlayer?
    private var alienLaserSound: AVAudioPlayer?
    private var explosionSound: AVAudioPlayer?
    private var backgroundMusic: AVAudioPlayer?

    // Game configuration
    private let screenWidth: CGFloat
    private let screenHeight: CGFloat
    private var alienDirection: CGFloat = 1.0
    private var extraSpawnTimer: Int = 0

    // Alien grid configuration
    private let alienRows = 7
    private let alienCols = 11
    private let alienXDistance: CGFloat = 60
    private let alienYDistance: CGFloat = 48
    private let alienXOffset: CGFloat = 70
    private let alienYOffset: CGFloat = 100

    // Obstacle configuration
    private let obstacleAmount = 6
    private let blockSize: CGFloat = 6
    private let obstacleShape = [
        "  xxxxxxx",
        " xxxxxxxxx",
        "xxxxxxxxxxx",
        "xxxxxxxxxxx",
        "xxxxxxxxxxx",
        "xxx     xxx",
        "xx       xx"
    ]

    override init(size: CGSize) {
        screenWidth = size.width
        screenHeight = size.height
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        setupPhysics()
        setupBackground()
        setupAudio()
        loadHomeScreenFrames()
        setupUI()
        showHomeScreen()
    }

    private func setupPhysics() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    private func setupBackground() {
        background = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
        background.position = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        background.size = size
        background.zPosition = -1
        addChild(background)

        // Add overlay for darker effect
        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.alpha = 0.1
        overlay.position = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        overlay.zPosition = 0
        addChild(overlay)
    }

    private func setupAudio() {
        // Setup background music
        if let musicURL = Bundle.main.url(forResource: "music", withExtension: "wav") {
            do {
                backgroundMusic = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusic?.volume = 0.2
                backgroundMusic?.numberOfLoops = -1
                backgroundMusic?.play()
            } catch {
                print("Failed to load background music: \(error)")
            }
        }

        // Setup laser sounds
        if let laserURL = Bundle.main.url(forResource: "laser", withExtension: "wav") {
            do {
                playerLaserSound = try AVAudioPlayer(contentsOf: laserURL)
                playerLaserSound?.volume = 0.2

                alienLaserSound = try AVAudioPlayer(contentsOf: laserURL)
                alienLaserSound?.volume = 0.5
            } catch {
                print("Failed to load laser sound: \(error)")
            }
        }

        // Setup explosion sound
        if let explosionURL = Bundle.main.url(forResource: "explosion", withExtension: "wav") {
            do {
                explosionSound = try AVAudioPlayer(contentsOf: explosionURL)
                explosionSound?.volume = 0.3
            } catch {
                print("Failed to load explosion sound: \(error)")
            }
        }
    }

    private func loadHomeScreenFrames() {
        // Load home screen GIF frames
        // For now, we'll just use the home.png as a single frame
        // In a real implementation, you'd extract frames from the GIF
        if let homeTexture = SKTexture(imageNamed: "home") {
            homeScreenFrames = [homeTexture]
        }
    }

    private func setupUI() {
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "Pixeled")
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 10, y: screenHeight - 30)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 100
        addChild(scoreLabel)

        // Lives icons will be added when game starts
    }

    private func showHomeScreen() {
        gameActive = false
        gameOver = false
        gameWon = false

        // Stop alien shooting
        stopAlienShooting()

        // Display home screen animation
        let homeScreenNode = SKSpriteNode(texture: homeScreenFrames.first)
        homeScreenNode.position = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        homeScreenNode.zPosition = 50
        addChild(homeScreenNode)

        // Animate through frames if multiple exist
        if homeScreenFrames.count > 1 {
            let animateAction = SKAction.animate(with: homeScreenFrames, timePerFrame: 0.1)
            let repeatAction = SKAction.repeatForever(animateAction)
            homeScreenNode.run(repeatAction)
        }
    }

    func resetGame() {
        // Stop any existing timers
        stopAlienShooting()

        // Remove all game objects
        removeAllChildren()

        // Re-setup background and UI
        setupBackground()
        setupUI()

        // Reset game state
        gameActive = true
        gameOver = false
        gameWon = false
        lives = 3
        score = 0
        alienDirection = 1.0
        extraSpawnTimer = Int.random(in: 40...80)

        // Clear arrays
        aliens.removeAll()
        alienLasers.removeAll()
        playerLasers.removeAll()
        blocks.removeAll()
        extraAlien = nil

        // Create game objects
        createPlayer()
        createAliens()
        createObstacles()
        updateUI()

        // Start alien shooting
        startAlienShooting()
    }

    private func createPlayer() {
        player = Player(position: CGPoint(x: screenWidth / 2, y: screenHeight - 50), screenWidth: screenWidth)
        addChild(player.sprite)
    }

    private func createAliens() {
        for row in 0..<alienRows {
            for col in 0..<alienCols {
                let x = CGFloat(col) * alienXDistance + alienXOffset
                let y = CGFloat(row) * alienYDistance + alienYOffset

                let color: Alien.AlienColor
                if row == 0 {
                    color = .yellow
                } else if row <= 2 {
                    color = .green
                } else {
                    color = .red
                }

                let alien = Alien(color: color, position: CGPoint(x: x, y: y))
                aliens.append(alien)
                addChild(alien.sprite)
            }
        }
    }

    private func createObstacles() {
        let obstacleXPositions = (0..<obstacleAmount).map { num in
            CGFloat(num) * (screenWidth / CGFloat(obstacleAmount))
        }

        for xOffset in obstacleXPositions {
            createObstacle(at: CGPoint(x: screenWidth / 15 + xOffset, y: 480))
        }
    }

    private func createObstacle(at position: CGPoint) {
        for (rowIndex, row) in obstacleShape.enumerated() {
            for (colIndex, char) in row.enumerated() {
                if char == "x" {
                    let x = position.x + CGFloat(colIndex) * blockSize
                    let y = position.y + CGFloat(obstacleShape.count - 1 - rowIndex) * blockSize
                    let block = Block(position: CGPoint(x: x, y: y), size: blockSize)
                    blocks.append(block)
                    addChild(block.sprite)
                }
            }
        }
    }

    private func updateUI() {
        scoreLabel.text = "score: \(score)"

        // Update lives display
        for icon in livesIcons {
            icon.removeFromParent()
        }
        livesIcons.removeAll()

        let liveTexture = SKTexture(imageNamed: "spaceship")
        for i in 0..<(lives - 1) {
            let icon = SKSpriteNode(texture: liveTexture)
            icon.position = CGPoint(x: screenWidth - 50 - CGFloat(i) * 60, y: screenHeight - 25)
            icon.zPosition = 100
            livesIcons.append(icon)
            addChild(icon)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if gameActive && !gameWon {
            updateGame()
        } else if gameWon {
            // When game is won, show home screen
            showHomeScreen()
        }
    }

    private func updateGame() {
        player.update()

        // Update aliens
        for alien in aliens {
            alien.update(direction: alienDirection)
        }

        // Check alien position boundaries
        checkAlienBoundaries()

        // Update lasers
        updateLasers()

        // Update extra alien timer
        updateExtraAlien()

        // Update extra alien if exists
        extraAlien?.update()

        // Check win/lose conditions
        checkGameEndConditions()

        // Update UI
        updateUI()
    }

    private func checkAlienBoundaries() {
        var shouldChangeDirection = false
        var moveDown = false

        for alien in aliens {
            if alien.sprite.position.x + alien.sprite.size.width / 2 >= screenWidth {
                shouldChangeDirection = true
                moveDown = true
                break
            } else if alien.sprite.position.x - alien.sprite.size.width / 2 <= 0 {
                shouldChangeDirection = true
                moveDown = true
                break
            }
        }

        if shouldChangeDirection {
            alienDirection *= -1
        }

        if moveDown {
            for alien in aliens {
                alien.sprite.position.y += 2  // Pygame moves DOWN (increases y), so we add
            }
        }
    }

    private func updateLasers() {
        // Update player lasers
        playerLasers = playerLasers.filter { laser in
            laser.update()
            if !laser.isActive {
                laser.sprite.removeFromParent()
                return false
            }
            return true
        }

        // Update alien lasers
        alienLasers = alienLasers.filter { laser in
            laser.update()
            if !laser.isActive {
                laser.sprite.removeFromParent()
                return false
            }
            return true
        }
    }

    private func updateExtraAlien() {
        extraSpawnTimer -= 1
        if extraSpawnTimer <= 0 {
            createExtraAlien()
            extraSpawnTimer = Int.random(in: 400...800)
        }
    }

    private func createExtraAlien() {
        let side = Bool.random() ? "right" : "left"
        extraAlien = Extra(side: side, screenWidth: screenWidth)
        addChild(extraAlien!.sprite)
    }


    private func checkGameEndConditions() {
        if aliens.isEmpty && !gameWon {
            gameWon = true
            stopAlienShooting()
            // Victory message will be shown briefly before transitioning to home screen
        } else if lives <= 0 && !gameOver {
            gameOver = true
            gameActive = false
            stopAlienShooting()
            showGameOverScreen()
        }
    }


    private func showGameOverScreen() {
        let gameOverLabel = SKLabelNode(fontNamed: "Pixeled")
        gameOverLabel.text = "Game Over. But you still get a special prize!"
        gameOverLabel.fontSize = 20
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        gameOverLabel.zPosition = 200
        addChild(gameOverLabel)

        let restartLabel = SKLabelNode(fontNamed: "Pixeled")
        restartLabel.text = "TAP to return to Home"
        restartLabel.fontSize = 16
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 50)
        restartLabel.zPosition = 200
        addChild(restartLabel)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if !gameActive || gameWon {
            // Handle home screen, game over screen, or victory screen taps
            resetGame()
        } else {
            // Handle in-game touches
            handleInGameTouch(at: location)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameActive, let touch = touches.first else { return }
        let location = touch.location(in: self)
        handleInGameTouch(at: location)
    }

    private func handleInGameTouch(at location: CGPoint) {
        let screenHeight = self.size.height

        if location.y < screenHeight * 0.8 {
            // Top 80% of screen for movement
            if location.x < size.width / 2 {
                // Left side - move left
                player.moveLeft()
            } else {
                // Right side - move right
                player.moveRight()
            }
        } else {
            // Bottom 20% of screen for shooting
            if let laser = player.shootLaser() {
                playerLasers.append(laser)
                addChild(laser.sprite)
                playerLaserSound?.play()
            }
        }
    }

    // MARK: - Alien Shooting Timer

    private var alienShootTimer: Timer?

    private func startAlienShooting() {
        alienShootTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
            self?.alienShoot()
        }
    }

    private func stopAlienShooting() {
        alienShootTimer?.invalidate()
        alienShootTimer = nil
    }

    private func alienShoot() {
        guard !aliens.isEmpty else { return }

        let randomAlien = aliens.randomElement()!
        let laser = Laser(position: randomAlien.sprite.position, speed: 6, direction: .down, screenHeight: screenHeight)
        alienLasers.append(laser)
        addChild(laser.sprite)
        alienLaserSound?.play()
    }

    // MARK: - Game State Changes

    private func pauseGame() {
        isPaused = true
        stopAlienShooting()
        backgroundMusic?.pause()
    }

    private func resumeGame() {
        isPaused = false
        if gameActive {
            startAlienShooting()
        }
        backgroundMusic?.play()
    }

    // MARK: - SKPhysicsContactDelegate

    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        // Handle collisions between different object types
        let categories = [bodyA.categoryBitMask, bodyB.categoryBitMask]

        // Player laser hits alien
        if categories.contains(PhysicsCategory.playerLaser) && categories.contains(PhysicsCategory.alien) {
            handlePlayerLaserAlienCollision(contact)
        }
        // Player laser hits block
        else if categories.contains(PhysicsCategory.playerLaser) && categories.contains(PhysicsCategory.block) {
            handlePlayerLaserBlockCollision(contact)
        }
        // Player laser hits extra
        else if categories.contains(PhysicsCategory.playerLaser) && categories.contains(PhysicsCategory.extra) {
            handlePlayerLaserExtraCollision(contact)
        }
        // Alien laser hits player
        else if categories.contains(PhysicsCategory.alienLaser) && categories.contains(PhysicsCategory.player) {
            handleAlienLaserPlayerCollision(contact)
        }
        // Alien laser hits block
        else if categories.contains(PhysicsCategory.alienLaser) && categories.contains(PhysicsCategory.block) {
            handleAlienLaserBlockCollision(contact)
        }
        // Alien hits block
        else if categories.contains(PhysicsCategory.alien) && categories.contains(PhysicsCategory.block) {
            handleAlienBlockCollision(contact)
        }
        // Alien hits player
        else if categories.contains(PhysicsCategory.alien) && categories.contains(PhysicsCategory.player) {
            handleAlienPlayerCollision(contact)
        }
    }

    private func handlePlayerLaserAlienCollision(_ contact: SKPhysicsContact) {
        let laserBody = contact.bodyA.categoryBitMask == PhysicsCategory.playerLaser ? contact.bodyA : contact.bodyB
        let alienBody = contact.bodyA.categoryBitMask == PhysicsCategory.alien ? contact.bodyA : contact.bodyB

        // Find and remove the laser
        if let laserIndex = playerLasers.firstIndex(where: { $0.sprite.physicsBody === laserBody }) {
            let laser = playerLasers[laserIndex]
            laser.sprite.removeFromParent()
            playerLasers.remove(at: laserIndex)
        }

        // Find and remove the alien
        if let alienIndex = aliens.firstIndex(where: { $0.sprite.physicsBody === alienBody }) {
            let alien = aliens[alienIndex]
            score += alien.pointValue
            alien.sprite.removeFromParent()
            aliens.remove(at: alienIndex)
            explosionSound?.play()
        }
    }

    private func handlePlayerLaserBlockCollision(_ contact: SKPhysicsContact) {
        let laserBody = contact.bodyA.categoryBitMask == PhysicsCategory.playerLaser ? contact.bodyA : contact.bodyB
        let blockBody = contact.bodyA.categoryBitMask == PhysicsCategory.block ? contact.bodyA : contact.bodyB

        // Find and remove the laser
        if let laserIndex = playerLasers.firstIndex(where: { $0.sprite.physicsBody === laserBody }) {
            let laser = playerLasers[laserIndex]
            laser.sprite.removeFromParent()
            playerLasers.remove(at: laserIndex)
        }

        // Find and remove the block
        if let blockIndex = blocks.firstIndex(where: { $0.sprite.physicsBody === blockBody }) {
            let block = blocks[blockIndex]
            block.sprite.removeFromParent()
            blocks.remove(at: blockIndex)
        }
    }

    private func handlePlayerLaserExtraCollision(_ contact: SKPhysicsContact) {
        let laserBody = contact.bodyA.categoryBitMask == PhysicsCategory.playerLaser ? contact.bodyA : contact.bodyB

        // Find and remove the laser
        if let laserIndex = playerLasers.firstIndex(where: { $0.sprite.physicsBody === laserBody }) {
            let laser = playerLasers[laserIndex]
            laser.sprite.removeFromParent()
            playerLasers.remove(at: laserIndex)
        }

        // Remove the extra alien
        if let extra = extraAlien {
            score += 500
            extra.sprite.removeFromParent()
            extraAlien = nil
            explosionSound?.play()
        }
    }

    private func handleAlienLaserPlayerCollision(_ contact: SKPhysicsContact) {
        let laserBody = contact.bodyA.categoryBitMask == PhysicsCategory.alienLaser ? contact.bodyA : contact.bodyB

        // Find and remove the laser
        if let laserIndex = alienLasers.firstIndex(where: { $0.sprite.physicsBody === laserBody }) {
            let laser = alienLasers[laserIndex]
            laser.sprite.removeFromParent()
            alienLasers.remove(at: laserIndex)
        }

        // Decrease lives
        lives -= 1
        if lives <= 0 {
            gameActive = false
            gameOver = true
        }
    }

    private func handleAlienLaserBlockCollision(_ contact: SKPhysicsContact) {
        let laserBody = contact.bodyA.categoryBitMask == PhysicsCategory.alienLaser ? contact.bodyA : contact.bodyB
        let blockBody = contact.bodyA.categoryBitMask == PhysicsCategory.block ? contact.bodyA : contact.bodyB

        // Find and remove the laser
        if let laserIndex = alienLasers.firstIndex(where: { $0.sprite.physicsBody === laserBody }) {
            let laser = alienLasers[laserIndex]
            laser.sprite.removeFromParent()
            alienLasers.remove(at: laserIndex)
        }

        // Find and remove the block
        if let blockIndex = blocks.firstIndex(where: { $0.sprite.physicsBody === blockBody }) {
            let block = blocks[blockIndex]
            block.sprite.removeFromParent()
            blocks.remove(at: blockIndex)
        }
    }

    private func handleAlienBlockCollision(_ contact: SKPhysicsContact) {
        let blockBody = contact.bodyA.categoryBitMask == PhysicsCategory.block ? contact.bodyA : contact.bodyB

        // Find and remove the block
        if let blockIndex = blocks.firstIndex(where: { $0.sprite.physicsBody === blockBody }) {
            let block = blocks[blockIndex]
            block.sprite.removeFromParent()
            blocks.remove(at: blockIndex)
        }
    }

    private func handleAlienPlayerCollision(_ contact: SKPhysicsContact) {
        gameActive = false
        gameOver = true
    }
}
