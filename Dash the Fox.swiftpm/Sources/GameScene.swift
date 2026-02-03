import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties
    var dash: SKNode!
    var ground: SKSpriteNode!
    var cameraNode: SKCameraNode!
    var goalFlag: SKNode!

    var gameState: GameState = .menu
    var currentLevel: LevelData!

    var isJumping = false
    var canDoubleJump = false
    var hasDoubleJumped = false
    var moveDirection: CGFloat = 0
    var score = 0
    var lives = 3

    // Power-up states
    var hasSpeedBoost = false
    var hasShield = false
    var hasMagnet = false
    var shieldNode: SKShapeNode?

    // UI Elements
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    var levelLabel: SKLabelNode!

    // Control buttons
    var leftButton: SKShapeNode!
    var rightButton: SKShapeNode!
    var jumpButton: SKShapeNode!

    // Menu/UI layers
    var menuLayer: SKNode!
    var gameOverLayer: SKNode!
    var levelCompleteLayer: SKNode!
    var pauseButton: SKShapeNode!

    // Physics categories
    let playerCategory: UInt32 = 0x1 << 0
    let groundCategory: UInt32 = 0x1 << 1
    let platformCategory: UInt32 = 0x1 << 2
    let coinCategory: UInt32 = 0x1 << 3
    let enemyCategory: UInt32 = 0x1 << 4
    let powerUpCategory: UInt32 = 0x1 << 5
    let goalCategory: UInt32 = 0x1 << 6

    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)

        physicsWorld.gravity = CGVector(dx: 0, dy: -20)
        physicsWorld.contactDelegate = self

        lives = PlayerData.shared.lives

        setupCamera()
        showMainMenu()
    }

    func setupCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
    }

    // MARK: - Main Menu
    func showMainMenu() {
        gameState = .menu
        clearGameElements()

        menuLayer = SKNode()
        menuLayer.zPosition = 200
        cameraNode.addChild(menuLayer)

        // Title
        let titleLabel = SKLabelNode(text: "Dash the Fox")
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = 56
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        titleLabel.position = CGPoint(x: 0, y: 120)
        menuLayer.addChild(titleLabel)

        // Animated fox on menu
        let menuFox = createFoxCharacter()
        menuFox.position = CGPoint(x: 0, y: 20)
        menuFox.setScale(1.5)
        menuLayer.addChild(menuFox)

        // Idle animation
        let breatheIn = SKAction.scaleY(to: 1.55, duration: 0.8)
        let breatheOut = SKAction.scaleY(to: 1.45, duration: 0.8)
        breatheIn.timingMode = .easeInEaseOut
        breatheOut.timingMode = .easeInEaseOut
        menuFox.run(SKAction.repeatForever(SKAction.sequence([breatheIn, breatheOut])))

        // Play button
        let playButton = createMenuButton(text: "Play", color: .orange)
        playButton.position = CGPoint(x: 0, y: -80)
        playButton.name = "playButton"
        menuLayer.addChild(playButton)

        // Level select button
        let levelButton = createMenuButton(text: "Levels", color: .blue)
        levelButton.position = CGPoint(x: 0, y: -160)
        levelButton.name = "levelButton"
        menuLayer.addChild(levelButton)

        // High scores display
        let coinsLabel = SKLabelNode(text: "Total Coins: \(PlayerData.shared.totalCoins)")
        coinsLabel.fontName = "AvenirNext-Medium"
        coinsLabel.fontSize = 24
        coinsLabel.fontColor = .yellow
        coinsLabel.position = CGPoint(x: 0, y: -240)
        menuLayer.addChild(coinsLabel)

        // Animate menu appearance
        menuLayer.alpha = 0
        menuLayer.run(SKAction.fadeIn(withDuration: 0.5))
    }

    func createMenuButton(text: String, color: SKColor) -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 15)
        bg.fillColor = color
        bg.strokeColor = color.withAlphaComponent(0.5)
        bg.lineWidth = 4
        button.addChild(bg)

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 28
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)

        return button
    }

    // MARK: - Level Select
    func showLevelSelect() {
        menuLayer?.removeFromParent()

        let levelSelectLayer = SKNode()
        levelSelectLayer.zPosition = 200
        levelSelectLayer.name = "levelSelectLayer"
        cameraNode.addChild(levelSelectLayer)

        let titleLabel = SKLabelNode(text: "Select Level")
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = 42
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 150)
        levelSelectLayer.addChild(titleLabel)

        for i in 1...LevelData.totalLevels {
            let isUnlocked = i <= PlayerData.shared.currentLevel
            let levelButton = createLevelButton(level: i, unlocked: isUnlocked)
            levelButton.position = CGPoint(x: CGFloat(i - 2) * 150, y: 0)
            levelButton.name = "level_\(i)"
            levelSelectLayer.addChild(levelButton)

            // Show high score
            if let highScore = PlayerData.shared.highScores[i] {
                let scoreLabel = SKLabelNode(text: "Best: \(highScore)")
                scoreLabel.fontName = "AvenirNext-Medium"
                scoreLabel.fontSize = 16
                scoreLabel.fontColor = .yellow
                scoreLabel.position = CGPoint(x: CGFloat(i - 2) * 150, y: -70)
                levelSelectLayer.addChild(scoreLabel)
            }
        }

        // Back button
        let backButton = createMenuButton(text: "Back", color: .gray)
        backButton.position = CGPoint(x: 0, y: -150)
        backButton.name = "backButton"
        levelSelectLayer.addChild(backButton)
    }

    func createLevelButton(level: Int, unlocked: Bool) -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(circleOfRadius: 50)
        bg.fillColor = unlocked ? .orange : .darkGray
        bg.strokeColor = unlocked ? .white : .gray
        bg.lineWidth = 4
        button.addChild(bg)

        let label = SKLabelNode(text: unlocked ? "\(level)" : "🔒")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = unlocked ? 36 : 28
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)

        return button
    }

    // MARK: - Start Game
    func startGame(level: Int) {
        gameState = .playing
        currentLevel = LevelData.level(level)
        score = 0
        hasDoubleJumped = false
        canDoubleJump = false
        hasSpeedBoost = false
        hasShield = false
        hasMagnet = false

        clearGameElements()
        menuLayer?.removeFromParent()
        cameraNode.childNode(withName: "levelSelectLayer")?.removeFromParent()
        gameOverLayer?.removeFromParent()
        levelCompleteLayer?.removeFromParent()

        backgroundColor = currentLevel.backgroundColors.sky

        setupDash()
        setupGround()
        setupPlatforms()
        setupCoins()
        setupEnemies()
        setupPowerUps()
        setupGoal()
        setupControls()
        setupHUD()
        setupBackground()
        setupPauseButton()
    }

    func clearGameElements() {
        // Remove all game objects
        children.filter { $0 != cameraNode }.forEach { $0.removeFromParent() }
        shieldNode?.removeFromParent()
        shieldNode = nil
    }

    // MARK: - Background
    func setupBackground() {
        // Add clouds
        for i in 0..<Int(currentLevel.levelLength / 400) {
            let cloud = createCloud()
            cloud.position = CGPoint(
                x: CGFloat(i) * 400 + CGFloat.random(in: -100...100),
                y: size.height * 0.7 + CGFloat.random(in: -50...50)
            )
            cloud.zPosition = -10
            addChild(cloud)
        }

        // Add hills in background
        for i in 0..<Int(currentLevel.levelLength / 300) {
            let hill = createHill()
            hill.position = CGPoint(
                x: CGFloat(i) * 300 - 200,
                y: 100
            )
            hill.zPosition = -5
            addChild(hill)
        }
    }

    func createCloud() -> SKNode {
        let cloud = SKShapeNode(ellipseOf: CGSize(width: 120, height: 60))
        cloud.fillColor = .white
        cloud.strokeColor = .clear
        cloud.alpha = 0.8

        let cloud2 = SKShapeNode(ellipseOf: CGSize(width: 80, height: 50))
        cloud2.fillColor = .white
        cloud2.strokeColor = .clear
        cloud2.position = CGPoint(x: 50, y: 10)
        cloud.addChild(cloud2)

        let cloud3 = SKShapeNode(ellipseOf: CGSize(width: 70, height: 45))
        cloud3.fillColor = .white
        cloud3.strokeColor = .clear
        cloud3.position = CGPoint(x: -40, y: 5)
        cloud.addChild(cloud3)

        return cloud
    }

    func createHill() -> SKNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -150, y: 0))
        path.addQuadCurve(to: CGPoint(x: 150, y: 0), control: CGPoint(x: 0, y: 150))
        path.closeSubpath()

        let hill = SKShapeNode(path: path)
        let levelNum = currentLevel.levelNumber
        switch levelNum {
        case 1:
            hill.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0)
        case 2:
            hill.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.5, alpha: 1.0)
        case 3:
            hill.fillColor = SKColor(red: 0.2, green: 0.25, blue: 0.4, alpha: 1.0)
        default:
            hill.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0)
        }
        hill.strokeColor = .clear

        return hill
    }

    // MARK: - Dash Setup
    func setupDash() {
        dash = createFoxCharacter()
        dash.position = CGPoint(x: 150, y: 300)
        dash.name = "dash"

        let body = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 50))
        body.categoryBitMask = playerCategory
        body.contactTestBitMask = groundCategory | platformCategory | coinCategory | enemyCategory | powerUpCategory | goalCategory
        body.collisionBitMask = groundCategory | platformCategory
        body.allowsRotation = false
        body.friction = 0.2
        body.restitution = 0
        dash.physicsBody = body

        addChild(dash)
    }

    func createFoxCharacter() -> SKNode {
        let fox = SKNode()

        // Body
        let body = SKShapeNode(ellipseOf: CGSize(width: 50, height: 40))
        body.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        body.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
        body.lineWidth = 2
        fox.addChild(body)

        // Head
        let head = SKShapeNode(circleOfRadius: 22)
        head.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        head.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
        head.lineWidth = 2
        head.position = CGPoint(x: 20, y: 15)
        fox.addChild(head)

        // Ears
        let earPath = CGMutablePath()
        earPath.move(to: CGPoint(x: 0, y: 0))
        earPath.addLine(to: CGPoint(x: 8, y: 20))
        earPath.addLine(to: CGPoint(x: 16, y: 0))
        earPath.closeSubpath()

        let leftEar = SKShapeNode(path: earPath)
        leftEar.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        leftEar.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
        leftEar.position = CGPoint(x: 5, y: 30)
        fox.addChild(leftEar)

        let rightEar = SKShapeNode(path: earPath)
        rightEar.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        rightEar.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
        rightEar.position = CGPoint(x: 22, y: 30)
        fox.addChild(rightEar)

        // Inner ears
        let innerEarPath = CGMutablePath()
        innerEarPath.move(to: CGPoint(x: 4, y: 2))
        innerEarPath.addLine(to: CGPoint(x: 8, y: 14))
        innerEarPath.addLine(to: CGPoint(x: 12, y: 2))
        innerEarPath.closeSubpath()

        let leftInnerEar = SKShapeNode(path: innerEarPath)
        leftInnerEar.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.7, alpha: 1.0)
        leftInnerEar.strokeColor = .clear
        leftInnerEar.position = CGPoint(x: 5, y: 30)
        fox.addChild(leftInnerEar)

        let rightInnerEar = SKShapeNode(path: innerEarPath)
        rightInnerEar.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.7, alpha: 1.0)
        rightInnerEar.strokeColor = .clear
        rightInnerEar.position = CGPoint(x: 22, y: 30)
        fox.addChild(rightInnerEar)

        // Snout
        let snout = SKShapeNode(ellipseOf: CGSize(width: 18, height: 14))
        snout.fillColor = .white
        snout.strokeColor = .clear
        snout.position = CGPoint(x: 32, y: 10)
        fox.addChild(snout)

        // Nose
        let nose = SKShapeNode(circleOfRadius: 4)
        nose.fillColor = .black
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 38, y: 12)
        fox.addChild(nose)

        // Eyes
        let leftEye = SKShapeNode(circleOfRadius: 5)
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: 18, y: 22)
        fox.addChild(leftEye)

        let leftPupil = SKShapeNode(circleOfRadius: 3)
        leftPupil.fillColor = .black
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: 20, y: 22)
        fox.addChild(leftPupil)

        let rightEye = SKShapeNode(circleOfRadius: 5)
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 28, y: 22)
        fox.addChild(rightEye)

        let rightPupil = SKShapeNode(circleOfRadius: 3)
        rightPupil.fillColor = .black
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: 30, y: 22)
        fox.addChild(rightPupil)

        // Tail
        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: 0, y: 0))
        tailPath.addQuadCurve(to: CGPoint(x: -40, y: 30), control: CGPoint(x: -30, y: 0))
        tailPath.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: -20, y: 20))

        let tail = SKShapeNode(path: tailPath)
        tail.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        tail.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
        tail.lineWidth = 2
        tail.position = CGPoint(x: -25, y: 0)
        tail.name = "tail"
        fox.addChild(tail)

        // Tail tip (white)
        let tailTipPath = CGMutablePath()
        tailTipPath.move(to: CGPoint(x: -35, y: 25))
        tailTipPath.addQuadCurve(to: CGPoint(x: -20, y: 15), control: CGPoint(x: -25, y: 25))

        let tailTip = SKShapeNode(path: tailTipPath)
        tailTip.strokeColor = .white
        tailTip.lineWidth = 6
        tailTip.lineCap = .round
        tailTip.position = CGPoint(x: -25, y: 0)
        fox.addChild(tailTip)

        // Legs
        let legColor = SKColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 1.0)

        let frontLeg = SKShapeNode(rectOf: CGSize(width: 10, height: 20))
        frontLeg.fillColor = legColor
        frontLeg.strokeColor = .clear
        frontLeg.position = CGPoint(x: 15, y: -25)
        frontLeg.name = "frontLeg"
        fox.addChild(frontLeg)

        let backLeg = SKShapeNode(rectOf: CGSize(width: 10, height: 20))
        backLeg.fillColor = legColor
        backLeg.strokeColor = .clear
        backLeg.position = CGPoint(x: -10, y: -25)
        backLeg.name = "backLeg"
        fox.addChild(backLeg)

        return fox
    }

    // MARK: - Ground Setup
    func setupGround() {
        let groundWidth = currentLevel.levelLength + 400
        ground = SKSpriteNode(color: currentLevel.backgroundColors.ground, size: CGSize(width: groundWidth, height: 100))
        ground.position = CGPoint(x: groundWidth / 2 - 200, y: 50)
        ground.name = "ground"

        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.friction = 0.8

        addChild(ground)

        // Grass on top
        let grass = SKSpriteNode(color: SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0), size: CGSize(width: groundWidth, height: 20))
        grass.position = CGPoint(x: 0, y: 60)
        ground.addChild(grass)
    }

    // MARK: - Platforms
    func setupPlatforms() {
        for (index, pos) in currentLevel.platforms.enumerated() {
            let platform = createPlatform(width: pos.width)
            platform.position = CGPoint(x: pos.x, y: pos.y)
            platform.name = "platform_\(index)"
            addChild(platform)
        }
    }

    func createPlatform(width: CGFloat) -> SKNode {
        let platform = SKSpriteNode(color: SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0), size: CGSize(width: width, height: 30))

        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = platformCategory
        platform.physicsBody?.friction = 0.8

        let grass = SKSpriteNode(color: SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0), size: CGSize(width: width, height: 8))
        grass.position = CGPoint(x: 0, y: 19)
        platform.addChild(grass)

        return platform
    }

    // MARK: - Coins
    func setupCoins() {
        for (index, pos) in currentLevel.coins.enumerated() {
            let coin = createCoin()
            coin.position = pos
            coin.name = "coin_\(index)"
            addChild(coin)
        }
    }

    func createCoin() -> SKNode {
        let coin = SKShapeNode(circleOfRadius: 15)
        coin.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
        coin.strokeColor = SKColor(red: 0.9, green: 0.7, blue: 0.0, alpha: 1.0)
        coin.lineWidth = 3

        let inner = SKShapeNode(circleOfRadius: 10)
        inner.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        inner.strokeColor = .clear
        coin.addChild(inner)

        coin.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = playerCategory

        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2)
        coin.run(SKAction.repeatForever(rotate))

        let moveUp = SKAction.moveBy(x: 0, y: 8, duration: 0.5)
        let moveDown = SKAction.moveBy(x: 0, y: -8, duration: 0.5)
        moveUp.timingMode = .easeInEaseOut
        moveDown.timingMode = .easeInEaseOut
        coin.run(SKAction.repeatForever(SKAction.sequence([moveUp, moveDown])))

        return coin
    }

    // MARK: - Enemies
    func setupEnemies() {
        for (index, enemyData) in currentLevel.enemies.enumerated() {
            let enemy = createEnemy(type: enemyData.type)
            enemy.position = enemyData.position
            enemy.name = "enemy_\(index)"
            addChild(enemy)

            // Movement based on type
            switch enemyData.type {
            case .spiky, .slime, .snake:
                let moveRight = SKAction.moveBy(x: 100, duration: 2)
                let moveLeft = SKAction.moveBy(x: -100, duration: 2)
                enemy.run(SKAction.repeatForever(SKAction.sequence([moveRight, moveLeft])))
            case .bat:
                let moveRight = SKAction.moveBy(x: 80, duration: 1.5)
                let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 0.75)
                let moveDown = SKAction.moveBy(x: 0, y: -40, duration: 0.75)
                let moveLeft = SKAction.moveBy(x: -80, duration: 1.5)
                let moveUp2 = SKAction.moveBy(x: 0, y: 40, duration: 0.75)
                let moveDown2 = SKAction.moveBy(x: 0, y: -40, duration: 0.75)
                enemy.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.group([moveRight, SKAction.sequence([moveUp, moveDown])]),
                    SKAction.group([moveLeft, SKAction.sequence([moveUp2, moveDown2])])
                ])))
            }
        }
    }

    func createEnemy(type: EnemyType) -> SKNode {
        switch type {
        case .spiky:
            return createSpikyEnemy()
        case .slime:
            return createSlimeEnemy()
        case .bat:
            return createBatEnemy()
        case .snake:
            return createSnakeEnemy()
        }
    }

    func createSpikyEnemy() -> SKNode {
        let enemy = SKNode()

        let body = SKShapeNode(circleOfRadius: 25)
        body.fillColor = SKColor(red: 0.3, green: 0.1, blue: 0.4, alpha: 1.0)
        body.strokeColor = SKColor(red: 0.5, green: 0.2, blue: 0.6, alpha: 1.0)
        body.lineWidth = 3
        enemy.addChild(body)

        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let spike = SKShapeNode(rectOf: CGSize(width: 8, height: 15))
            spike.fillColor = SKColor(red: 0.5, green: 0.2, blue: 0.6, alpha: 1.0)
            spike.strokeColor = .clear
            spike.position = CGPoint(x: cos(angle) * 30, y: sin(angle) * 30)
            spike.zRotation = angle
            enemy.addChild(spike)
        }

        addEnemyEyes(to: enemy, color: .red)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory

        // Rotate spikes
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 3)
        enemy.run(SKAction.repeatForever(rotate))

        return enemy
    }

    func createSlimeEnemy() -> SKNode {
        let enemy = SKNode()

        // Slime body (blob shape)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -25, y: 0))
        path.addQuadCurve(to: CGPoint(x: 0, y: 30), control: CGPoint(x: -20, y: 35))
        path.addQuadCurve(to: CGPoint(x: 25, y: 0), control: CGPoint(x: 20, y: 35))
        path.addLine(to: CGPoint(x: -25, y: 0))
        path.closeSubpath()

        let body = SKShapeNode(path: path)
        body.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
        body.strokeColor = SKColor(red: 0.1, green: 0.6, blue: 0.2, alpha: 1.0)
        body.lineWidth = 3
        enemy.addChild(body)

        addEnemyEyes(to: enemy, color: .black, yOffset: 15)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 22)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory

        // Bounce animation
        let squish = SKAction.scaleY(to: 0.7, duration: 0.3)
        let stretch = SKAction.scaleY(to: 1.2, duration: 0.3)
        let normal = SKAction.scaleY(to: 1.0, duration: 0.2)
        squish.timingMode = .easeOut
        stretch.timingMode = .easeOut
        enemy.run(SKAction.repeatForever(SKAction.sequence([squish, stretch, normal])))

        return enemy
    }

    func createBatEnemy() -> SKNode {
        let enemy = SKNode()

        // Body
        let body = SKShapeNode(ellipseOf: CGSize(width: 30, height: 25))
        body.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        body.strokeColor = .clear
        enemy.addChild(body)

        // Wings
        let wingPath = CGMutablePath()
        wingPath.move(to: CGPoint(x: 0, y: 0))
        wingPath.addQuadCurve(to: CGPoint(x: 35, y: -10), control: CGPoint(x: 20, y: 15))
        wingPath.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: 15, y: -5))

        let leftWing = SKShapeNode(path: wingPath)
        leftWing.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.4, alpha: 1.0)
        leftWing.strokeColor = .clear
        leftWing.position = CGPoint(x: -15, y: 5)
        leftWing.name = "leftWing"
        enemy.addChild(leftWing)

        let rightWing = SKShapeNode(path: wingPath)
        rightWing.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.4, alpha: 1.0)
        rightWing.strokeColor = .clear
        rightWing.xScale = -1
        rightWing.position = CGPoint(x: 15, y: 5)
        rightWing.name = "rightWing"
        enemy.addChild(rightWing)

        // Ears
        let earPath = CGMutablePath()
        earPath.move(to: CGPoint(x: 0, y: 0))
        earPath.addLine(to: CGPoint(x: 5, y: 15))
        earPath.addLine(to: CGPoint(x: 10, y: 0))

        let leftEar = SKShapeNode(path: earPath)
        leftEar.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        leftEar.strokeColor = .clear
        leftEar.position = CGPoint(x: -10, y: 8)
        enemy.addChild(leftEar)

        let rightEar = SKShapeNode(path: earPath)
        rightEar.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        rightEar.strokeColor = .clear
        rightEar.position = CGPoint(x: 0, y: 8)
        enemy.addChild(rightEar)

        addEnemyEyes(to: enemy, color: .yellow, size: 4)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory

        // Wing flap animation
        let flapUp = SKAction.rotate(toAngle: 0.5, duration: 0.15)
        let flapDown = SKAction.rotate(toAngle: -0.3, duration: 0.15)
        let wingFlap = SKAction.repeatForever(SKAction.sequence([flapUp, flapDown]))

        leftWing.run(wingFlap)
        rightWing.run(wingFlap.reversed())

        return enemy
    }

    func createSnakeEnemy() -> SKNode {
        let enemy = SKNode()

        // Snake body segments
        let segmentColor = SKColor(red: 0.6, green: 0.4, blue: 0.1, alpha: 1.0)

        for i in 0..<5 {
            let segment = SKShapeNode(circleOfRadius: CGFloat(12 - i))
            segment.fillColor = segmentColor
            segment.strokeColor = SKColor(red: 0.5, green: 0.3, blue: 0.0, alpha: 1.0)
            segment.lineWidth = 2
            segment.position = CGPoint(x: CGFloat(-i * 12), y: 0)
            enemy.addChild(segment)
        }

        // Head
        let head = SKShapeNode(ellipseOf: CGSize(width: 28, height: 20))
        head.fillColor = segmentColor
        head.strokeColor = SKColor(red: 0.5, green: 0.3, blue: 0.0, alpha: 1.0)
        head.lineWidth = 2
        head.position = CGPoint(x: 20, y: 0)
        enemy.addChild(head)

        // Eyes
        let leftEye = SKShapeNode(circleOfRadius: 4)
        leftEye.fillColor = .yellow
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: 25, y: 5)
        enemy.addChild(leftEye)

        let leftPupil = SKShapeNode(circleOfRadius: 2)
        leftPupil.fillColor = .black
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: 26, y: 5)
        enemy.addChild(leftPupil)

        // Tongue
        let tongue = SKShapeNode(rectOf: CGSize(width: 15, height: 3))
        tongue.fillColor = .red
        tongue.strokeColor = .clear
        tongue.position = CGPoint(x: 38, y: 0)
        tongue.name = "tongue"
        enemy.addChild(tongue)

        // Tongue animation
        let tongueOut = SKAction.moveBy(x: 8, y: 0, duration: 0.2)
        let tongueIn = SKAction.moveBy(x: -8, y: 0, duration: 0.2)
        let wait = SKAction.wait(forDuration: 1.0)
        tongue.run(SKAction.repeatForever(SKAction.sequence([tongueOut, tongueIn, wait])))

        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 24))
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory

        // Slither animation
        let slitherUp = SKAction.moveBy(x: 0, y: 3, duration: 0.2)
        let slitherDown = SKAction.moveBy(x: 0, y: -3, duration: 0.2)
        enemy.run(SKAction.repeatForever(SKAction.sequence([slitherUp, slitherDown])))

        return enemy
    }

    func addEnemyEyes(to node: SKNode, color: SKColor, size: CGFloat = 6, yOffset: CGFloat = 5) {
        let leftEye = SKShapeNode(circleOfRadius: size)
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -8, y: yOffset)
        node.addChild(leftEye)

        let leftPupil = SKShapeNode(circleOfRadius: size * 0.5)
        leftPupil.fillColor = color
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: -8, y: yOffset)
        node.addChild(leftPupil)

        let rightEye = SKShapeNode(circleOfRadius: size)
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 8, y: yOffset)
        node.addChild(rightEye)

        let rightPupil = SKShapeNode(circleOfRadius: size * 0.5)
        rightPupil.fillColor = color
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: 8, y: yOffset)
        node.addChild(rightPupil)
    }

    // MARK: - Power-ups
    func setupPowerUps() {
        for (index, powerUpData) in currentLevel.powerUps.enumerated() {
            let powerUp = createPowerUp(type: powerUpData.type)
            powerUp.position = powerUpData.position
            powerUp.name = "powerup_\(index)"
            powerUp.userData = ["type": powerUpData.type]
            addChild(powerUp)
        }
    }

    func createPowerUp(type: PowerUpType) -> SKNode {
        let powerUp = SKNode()

        // Outer glow
        let glow = SKShapeNode(circleOfRadius: 25)
        glow.fillColor = type.color.withAlphaComponent(0.3)
        glow.strokeColor = .clear
        powerUp.addChild(glow)

        // Pulsing glow
        let pulseOut = SKAction.scale(to: 1.3, duration: 0.5)
        let pulseIn = SKAction.scale(to: 1.0, duration: 0.5)
        glow.run(SKAction.repeatForever(SKAction.sequence([pulseOut, pulseIn])))

        // Main body
        let body = SKShapeNode(circleOfRadius: 18)
        body.fillColor = type.color
        body.strokeColor = .white
        body.lineWidth = 3
        powerUp.addChild(body)

        // Icon
        let icon = SKLabelNode(text: type.icon)
        icon.fontName = "AvenirNext-Bold"
        icon.fontSize = 20
        icon.fontColor = .white
        icon.verticalAlignmentMode = .center
        powerUp.addChild(icon)

        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: 18)
        powerUp.physicsBody?.isDynamic = false
        powerUp.physicsBody?.categoryBitMask = powerUpCategory
        powerUp.physicsBody?.contactTestBitMask = playerCategory

        // Float animation
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.6)
        let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 0.6)
        moveUp.timingMode = .easeInEaseOut
        moveDown.timingMode = .easeInEaseOut
        powerUp.run(SKAction.repeatForever(SKAction.sequence([moveUp, moveDown])))

        return powerUp
    }

    // MARK: - Goal
    func setupGoal() {
        goalFlag = createGoalFlag()
        goalFlag.position = currentLevel.goalPosition
        goalFlag.name = "goal"
        addChild(goalFlag)
    }

    func createGoalFlag() -> SKNode {
        let goal = SKNode()

        // Pole
        let pole = SKShapeNode(rectOf: CGSize(width: 8, height: 150))
        pole.fillColor = SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0)
        pole.strokeColor = .clear
        pole.position = CGPoint(x: 0, y: 75)
        goal.addChild(pole)

        // Flag
        let flagPath = CGMutablePath()
        flagPath.move(to: CGPoint(x: 0, y: 0))
        flagPath.addLine(to: CGPoint(x: 60, y: -20))
        flagPath.addLine(to: CGPoint(x: 0, y: -40))
        flagPath.closeSubpath()

        let flag = SKShapeNode(path: flagPath)
        flag.fillColor = .red
        flag.strokeColor = SKColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
        flag.lineWidth = 2
        flag.position = CGPoint(x: 4, y: 145)
        flag.name = "flag"
        goal.addChild(flag)

        // Star on flag
        let star = SKLabelNode(text: "★")
        star.fontName = "AvenirNext-Bold"
        star.fontSize = 24
        star.fontColor = .yellow
        star.position = CGPoint(x: 25, y: -25)
        flag.addChild(star)

        // Wave animation
        let waveRight = SKAction.rotate(toAngle: 0.1, duration: 0.5)
        let waveLeft = SKAction.rotate(toAngle: -0.05, duration: 0.5)
        waveRight.timingMode = .easeInEaseOut
        waveLeft.timingMode = .easeInEaseOut
        flag.run(SKAction.repeatForever(SKAction.sequence([waveRight, waveLeft])))

        goal.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 150), center: CGPoint(x: 30, y: 75))
        goal.physicsBody?.isDynamic = false
        goal.physicsBody?.categoryBitMask = goalCategory
        goal.physicsBody?.contactTestBitMask = playerCategory

        return goal
    }

    // MARK: - Controls
    func setupControls() {
        leftButton = SKShapeNode(circleOfRadius: 40)
        leftButton.fillColor = SKColor.white.withAlphaComponent(0.3)
        leftButton.strokeColor = SKColor.white.withAlphaComponent(0.6)
        leftButton.lineWidth = 3
        leftButton.name = "leftButton"
        leftButton.zPosition = 100
        cameraNode.addChild(leftButton)

        let leftArrow = SKLabelNode(text: "<")
        leftArrow.fontName = "AvenirNext-Bold"
        leftArrow.fontSize = 36
        leftArrow.fontColor = .white
        leftArrow.verticalAlignmentMode = .center
        leftButton.addChild(leftArrow)

        rightButton = SKShapeNode(circleOfRadius: 40)
        rightButton.fillColor = SKColor.white.withAlphaComponent(0.3)
        rightButton.strokeColor = SKColor.white.withAlphaComponent(0.6)
        rightButton.lineWidth = 3
        rightButton.name = "rightButton"
        rightButton.zPosition = 100
        cameraNode.addChild(rightButton)

        let rightArrow = SKLabelNode(text: ">")
        rightArrow.fontName = "AvenirNext-Bold"
        rightArrow.fontSize = 36
        rightArrow.fontColor = .white
        rightArrow.verticalAlignmentMode = .center
        rightButton.addChild(rightArrow)

        jumpButton = SKShapeNode(circleOfRadius: 50)
        jumpButton.fillColor = SKColor.orange.withAlphaComponent(0.4)
        jumpButton.strokeColor = SKColor.orange.withAlphaComponent(0.8)
        jumpButton.lineWidth = 3
        jumpButton.name = "jumpButton"
        jumpButton.zPosition = 100
        cameraNode.addChild(jumpButton)

        let jumpLabel = SKLabelNode(text: "JUMP")
        jumpLabel.fontName = "AvenirNext-Bold"
        jumpLabel.fontSize = 18
        jumpLabel.fontColor = .white
        jumpLabel.verticalAlignmentMode = .center
        jumpButton.addChild(jumpLabel)

        updateControlPositions()
    }

    func setupPauseButton() {
        pauseButton = SKShapeNode(rectOf: CGSize(width: 50, height: 50), cornerRadius: 10)
        pauseButton.fillColor = SKColor.black.withAlphaComponent(0.3)
        pauseButton.strokeColor = .white
        pauseButton.lineWidth = 2
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 100
        pauseButton.position = CGPoint(x: size.width / 2 - 40, y: size.height / 2 - 40)
        cameraNode.addChild(pauseButton)

        let pauseIcon = SKLabelNode(text: "||")
        pauseIcon.fontName = "AvenirNext-Bold"
        pauseIcon.fontSize = 24
        pauseIcon.fontColor = .white
        pauseIcon.verticalAlignmentMode = .center
        pauseButton.addChild(pauseIcon)
    }

    func updateControlPositions() {
        let bottomY = -size.height / 2 + 80
        leftButton?.position = CGPoint(x: -size.width / 2 + 70, y: bottomY)
        rightButton?.position = CGPoint(x: -size.width / 2 + 170, y: bottomY)
        jumpButton?.position = CGPoint(x: size.width / 2 - 80, y: bottomY)
    }

    // MARK: - HUD
    func setupHUD() {
        scoreLabel = SKLabelNode(text: "Coins: 0")
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .yellow
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: -size.width / 2 + 20, y: size.height / 2 - 40)
        scoreLabel.zPosition = 100
        cameraNode.addChild(scoreLabel)

        livesLabel = SKLabelNode(text: "Lives: \(lives)")
        livesLabel.fontName = "AvenirNext-Bold"
        livesLabel.fontSize = 24
        livesLabel.fontColor = .red
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.position = CGPoint(x: -size.width / 2 + 20, y: size.height / 2 - 70)
        livesLabel.zPosition = 100
        cameraNode.addChild(livesLabel)

        levelLabel = SKLabelNode(text: "Level \(currentLevel.levelNumber)")
        levelLabel.fontName = "AvenirNext-Bold"
        levelLabel.fontSize = 24
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: 0, y: size.height / 2 - 40)
        levelLabel.zPosition = 100
        cameraNode.addChild(levelLabel)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            handleTouch(touch, began: true)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            handleTouch(touch, began: false)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveDirection = 0
    }

    func handleTouch(_ touch: UITouch, began: Bool) {
        let location = touch.location(in: cameraNode)
        let nodes = cameraNode.nodes(at: location)

        for node in nodes {
            let nodeName = node.name ?? node.parent?.name ?? ""

            // Menu buttons
            if gameState == .menu {
                if began && nodeName == "playButton" {
                    startGame(level: PlayerData.shared.currentLevel)
                    return
                }
                if began && nodeName == "levelButton" {
                    showLevelSelect()
                    return
                }
            }

            // Level select buttons
            if nodeName.hasPrefix("level_") && began {
                if let levelNum = Int(nodeName.replacingOccurrences(of: "level_", with: "")) {
                    if levelNum <= PlayerData.shared.currentLevel {
                        startGame(level: levelNum)
                        return
                    }
                }
            }

            if nodeName == "backButton" && began {
                cameraNode.childNode(withName: "levelSelectLayer")?.removeFromParent()
                showMainMenu()
                return
            }

            // Game over / level complete buttons
            if began && (nodeName == "retryButton" || nodeName == "nextButton" || nodeName == "menuButton") {
                if nodeName == "retryButton" {
                    startGame(level: currentLevel.levelNumber)
                } else if nodeName == "nextButton" {
                    let nextLevel = min(currentLevel.levelNumber + 1, LevelData.totalLevels)
                    startGame(level: nextLevel)
                } else if nodeName == "menuButton" {
                    showMainMenu()
                }
                return
            }

            // Pause button
            if began && nodeName == "pauseButton" {
                togglePause()
                return
            }

            // Game controls
            if gameState == .playing {
                if nodeName == "leftButton" {
                    if began {
                        moveDirection = -1
                        flipDash(facingRight: false)
                    } else {
                        if moveDirection < 0 { moveDirection = 0 }
                    }
                } else if nodeName == "rightButton" {
                    if began {
                        moveDirection = 1
                        flipDash(facingRight: true)
                    } else {
                        if moveDirection > 0 { moveDirection = 0 }
                    }
                } else if nodeName == "jumpButton" && began {
                    jump()
                }
            }
        }
    }

    func togglePause() {
        if gameState == .playing {
            gameState = .paused
            isPaused = true
            showPauseMenu()
        } else if gameState == .paused {
            gameState = .playing
            isPaused = false
            cameraNode.childNode(withName: "pauseMenu")?.removeFromParent()
        }
    }

    func showPauseMenu() {
        let pauseMenu = SKNode()
        pauseMenu.name = "pauseMenu"
        pauseMenu.zPosition = 150

        let bg = SKShapeNode(rectOf: CGSize(width: 300, height: 250), cornerRadius: 20)
        bg.fillColor = SKColor.black.withAlphaComponent(0.8)
        bg.strokeColor = .white
        bg.lineWidth = 3
        pauseMenu.addChild(bg)

        let pauseLabel = SKLabelNode(text: "PAUSED")
        pauseLabel.fontName = "AvenirNext-Bold"
        pauseLabel.fontSize = 36
        pauseLabel.fontColor = .white
        pauseLabel.position = CGPoint(x: 0, y: 60)
        pauseMenu.addChild(pauseLabel)

        let resumeButton = createMenuButton(text: "Resume", color: .green)
        resumeButton.position = CGPoint(x: 0, y: 0)
        resumeButton.name = "pauseButton"
        pauseMenu.addChild(resumeButton)

        let menuButton = createMenuButton(text: "Menu", color: .gray)
        menuButton.position = CGPoint(x: 0, y: -70)
        menuButton.name = "menuButton"
        pauseMenu.addChild(menuButton)

        cameraNode.addChild(pauseMenu)
    }

    func flipDash(facingRight: Bool) {
        dash?.xScale = facingRight ? 1 : -1
    }

    func jump() {
        guard let body = dash?.physicsBody else { return }

        let onGround = abs(body.velocity.dy) < 10

        if onGround {
            body.applyImpulse(CGVector(dx: 0, dy: 450))
            hasDoubleJumped = false
            playJumpEffect()
        } else if canDoubleJump && !hasDoubleJumped {
            body.velocity.dy = 0
            body.applyImpulse(CGVector(dx: 0, dy: 400))
            hasDoubleJumped = true
            playJumpEffect()

            // Double jump visual effect
            let burstEffect = SKShapeNode(circleOfRadius: 20)
            burstEffect.fillColor = .clear
            burstEffect.strokeColor = .magenta
            burstEffect.lineWidth = 3
            burstEffect.position = dash.position
            burstEffect.zPosition = 5
            addChild(burstEffect)

            let expand = SKAction.scale(to: 3, duration: 0.3)
            let fade = SKAction.fadeOut(withDuration: 0.3)
            burstEffect.run(SKAction.sequence([SKAction.group([expand, fade]), SKAction.removeFromParent()]))
        }
    }

    func playJumpEffect() {
        let squish = SKAction.scaleY(to: 0.8, duration: 0.1)
        let stretch = SKAction.scaleY(to: 1.1, duration: 0.1)
        let normal = SKAction.scaleY(to: 1.0, duration: 0.1)
        dash?.run(SKAction.sequence([squish, stretch, normal]))
    }

    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        guard gameState == .playing else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == playerCategory | coinCategory {
            let coinNode = contact.bodyA.categoryBitMask == coinCategory ? contact.bodyA.node : contact.bodyB.node
            collectCoin(coinNode)
        }

        if collision == playerCategory | enemyCategory {
            if !hasShield {
                hitEnemy()
            } else {
                // Shield absorbs hit
                removeShield()
            }
        }

        if collision == playerCategory | powerUpCategory {
            let powerUpNode = contact.bodyA.categoryBitMask == powerUpCategory ? contact.bodyA.node : contact.bodyB.node
            collectPowerUp(powerUpNode)
        }

        if collision == playerCategory | goalCategory {
            reachGoal()
        }
    }

    func collectCoin(_ coin: SKNode?) {
        guard let coin = coin else { return }

        score += 1
        PlayerData.shared.totalCoins += 1
        scoreLabel?.text = "Coins: \(score)"

        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        coin.run(SKAction.sequence([scaleUp, fadeOut, remove]))

        let scorePopup = SKLabelNode(text: "+1")
        scorePopup.fontName = "AvenirNext-Bold"
        scorePopup.fontSize = 24
        scorePopup.fontColor = .yellow
        scorePopup.position = coin.position
        scorePopup.zPosition = 50
        addChild(scorePopup)

        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        let group = SKAction.group([moveUp, fade])
        scorePopup.run(SKAction.sequence([group, SKAction.removeFromParent()]))
    }

    func collectPowerUp(_ powerUp: SKNode?) {
        guard let powerUp = powerUp, let userData = powerUp.userData,
              let type = userData["type"] as? PowerUpType else { return }

        // Apply power-up effect
        switch type {
        case .speedBoost:
            activateSpeedBoost()
        case .doubleJump:
            activateDoubleJump()
        case .shield:
            activateShield()
        case .magnet:
            activateMagnet()
        }

        // Collection effect
        let burst = SKShapeNode(circleOfRadius: 30)
        burst.fillColor = type.color.withAlphaComponent(0.5)
        burst.strokeColor = type.color
        burst.lineWidth = 3
        burst.position = powerUp.position
        burst.zPosition = 50
        addChild(burst)

        let expand = SKAction.scale(to: 3, duration: 0.3)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        burst.run(SKAction.sequence([SKAction.group([expand, fade]), SKAction.removeFromParent()]))

        powerUp.removeFromParent()

        // Show power-up name
        let powerUpLabel = SKLabelNode(text: "\(type)".uppercased())
        powerUpLabel.fontName = "AvenirNext-Bold"
        powerUpLabel.fontSize = 20
        powerUpLabel.fontColor = type.color
        powerUpLabel.position = CGPoint(x: powerUp.position.x, y: powerUp.position.y + 40)
        powerUpLabel.zPosition = 50
        addChild(powerUpLabel)

        let rise = SKAction.moveBy(x: 0, y: 30, duration: 0.8)
        let fadeLabel = SKAction.fadeOut(withDuration: 0.8)
        powerUpLabel.run(SKAction.sequence([SKAction.group([rise, fadeLabel]), SKAction.removeFromParent()]))
    }

    func activateSpeedBoost() {
        hasSpeedBoost = true

        // Visual trail effect
        let trailAction = SKAction.run { [weak self] in
            guard let self = self, self.hasSpeedBoost, let dash = self.dash else { return }
            let ghost = SKShapeNode(circleOfRadius: 20)
            ghost.fillColor = .cyan.withAlphaComponent(0.3)
            ghost.strokeColor = .clear
            ghost.position = dash.position
            ghost.zPosition = -1
            self.addChild(ghost)
            ghost.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3), SKAction.removeFromParent()]))
        }
        let wait = SKAction.wait(forDuration: 0.05)
        let trailSequence = SKAction.sequence([trailAction, wait])
        run(SKAction.repeat(trailSequence, count: Int(PowerUpType.speedBoost.duration / 0.05)), withKey: "speedTrail")

        // Deactivate after duration
        run(SKAction.sequence([
            SKAction.wait(forDuration: PowerUpType.speedBoost.duration),
            SKAction.run { [weak self] in self?.hasSpeedBoost = false }
        ]), withKey: "speedBoost")
    }

    func activateDoubleJump() {
        canDoubleJump = true
        hasDoubleJumped = false

        run(SKAction.sequence([
            SKAction.wait(forDuration: PowerUpType.doubleJump.duration),
            SKAction.run { [weak self] in self?.canDoubleJump = false }
        ]), withKey: "doubleJump")
    }

    func activateShield() {
        hasShield = true

        // Create shield visual
        shieldNode?.removeFromParent()
        shieldNode = SKShapeNode(circleOfRadius: 45)
        shieldNode?.fillColor = SKColor.blue.withAlphaComponent(0.2)
        shieldNode?.strokeColor = .cyan
        shieldNode?.lineWidth = 3
        shieldNode?.zPosition = 10
        dash?.addChild(shieldNode!)

        // Pulse animation
        let pulseOut = SKAction.scale(to: 1.1, duration: 0.5)
        let pulseIn = SKAction.scale(to: 0.9, duration: 0.5)
        shieldNode?.run(SKAction.repeatForever(SKAction.sequence([pulseOut, pulseIn])))

        run(SKAction.sequence([
            SKAction.wait(forDuration: PowerUpType.shield.duration),
            SKAction.run { [weak self] in self?.removeShield() }
        ]), withKey: "shield")
    }

    func removeShield() {
        hasShield = false

        // Shield break effect
        if let shieldPos = shieldNode?.parent?.position {
            for i in 0..<8 {
                let shard = SKShapeNode(rectOf: CGSize(width: 10, height: 20))
                shard.fillColor = .cyan
                shard.strokeColor = .clear
                shard.position = shieldPos
                shard.zPosition = 50
                addChild(shard)

                let angle = CGFloat(i) * .pi / 4
                let moveOut = SKAction.moveBy(x: cos(angle) * 60, y: sin(angle) * 60, duration: 0.3)
                let rotate = SKAction.rotate(byAngle: .pi, duration: 0.3)
                let fade = SKAction.fadeOut(withDuration: 0.3)
                shard.run(SKAction.sequence([SKAction.group([moveOut, rotate, fade]), SKAction.removeFromParent()]))
            }
        }

        shieldNode?.removeFromParent()
        shieldNode = nil
        removeAction(forKey: "shield")
    }

    func activateMagnet() {
        hasMagnet = true

        run(SKAction.sequence([
            SKAction.wait(forDuration: PowerUpType.magnet.duration),
            SKAction.run { [weak self] in self?.hasMagnet = false }
        ]), withKey: "magnet")
    }

    func hitEnemy() {
        lives -= 1
        PlayerData.shared.lives = lives
        livesLabel?.text = "Lives: \(lives)"

        // Flash red
        let flashRed = SKAction.run { [weak self] in
            self?.dash?.children.compactMap { $0 as? SKShapeNode }.forEach { $0.fillColor = .red }
        }
        let flashNormal = SKAction.run { [weak self] in
            self?.dash?.removeFromParent()
            self?.setupDash()
        }
        dash?.run(SKAction.sequence([flashRed, SKAction.wait(forDuration: 0.1), flashNormal]))

        // Knockback
        let knockback = CGVector(dx: -moveDirection * 200, dy: 300)
        dash?.physicsBody?.velocity = CGVector.zero
        dash?.physicsBody?.applyImpulse(knockback)

        if lives <= 0 {
            gameOver()
        }
    }

    func reachGoal() {
        guard gameState == .playing else { return }
        gameState = .levelComplete

        // Update player data
        PlayerData.shared.updateHighScore(level: currentLevel.levelNumber, score: score)
        if currentLevel.levelNumber >= PlayerData.shared.currentLevel {
            PlayerData.shared.currentLevel = min(currentLevel.levelNumber + 1, LevelData.totalLevels)
        }
        PlayerData.shared.save()

        // Victory animation
        let jump1 = SKAction.moveBy(x: 0, y: 50, duration: 0.3)
        let jump2 = SKAction.moveBy(x: 0, y: -50, duration: 0.3)
        dash?.run(SKAction.sequence([jump1, jump2, jump1, jump2]))

        // Show level complete screen
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.run { [weak self] in self?.showLevelComplete() }
        ]))
    }

    func showLevelComplete() {
        levelCompleteLayer = SKNode()
        levelCompleteLayer.zPosition = 200
        cameraNode.addChild(levelCompleteLayer)

        let bg = SKShapeNode(rectOf: CGSize(width: 350, height: 300), cornerRadius: 20)
        bg.fillColor = SKColor.black.withAlphaComponent(0.8)
        bg.strokeColor = .yellow
        bg.lineWidth = 4
        levelCompleteLayer.addChild(bg)

        let completeLabel = SKLabelNode(text: "LEVEL COMPLETE!")
        completeLabel.fontName = "AvenirNext-Bold"
        completeLabel.fontSize = 32
        completeLabel.fontColor = .yellow
        completeLabel.position = CGPoint(x: 0, y: 90)
        levelCompleteLayer.addChild(completeLabel)

        let scoreText = SKLabelNode(text: "Coins: \(score)")
        scoreText.fontName = "AvenirNext-Medium"
        scoreText.fontSize = 24
        scoreText.fontColor = .white
        scoreText.position = CGPoint(x: 0, y: 40)
        levelCompleteLayer.addChild(scoreText)

        let highScoreText = SKLabelNode(text: "Best: \(PlayerData.shared.highScores[currentLevel.levelNumber] ?? score)")
        highScoreText.fontName = "AvenirNext-Medium"
        highScoreText.fontSize = 20
        highScoreText.fontColor = .gray
        highScoreText.position = CGPoint(x: 0, y: 10)
        levelCompleteLayer.addChild(highScoreText)

        if currentLevel.levelNumber < LevelData.totalLevels {
            let nextButton = createMenuButton(text: "Next Level", color: .green)
            nextButton.position = CGPoint(x: 0, y: -50)
            nextButton.name = "nextButton"
            levelCompleteLayer.addChild(nextButton)
        }

        let menuButton = createMenuButton(text: "Menu", color: .gray)
        menuButton.position = CGPoint(x: 0, y: -120)
        menuButton.name = "menuButton"
        levelCompleteLayer.addChild(menuButton)
    }

    func gameOver() {
        gameState = .gameOver
        PlayerData.shared.lives = 3
        PlayerData.shared.save()

        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in self?.showGameOver() }
        ]))
    }

    func showGameOver() {
        gameOverLayer = SKNode()
        gameOverLayer.zPosition = 200
        cameraNode.addChild(gameOverLayer)

        let bg = SKShapeNode(rectOf: CGSize(width: 350, height: 280), cornerRadius: 20)
        bg.fillColor = SKColor.black.withAlphaComponent(0.8)
        bg.strokeColor = .red
        bg.lineWidth = 4
        gameOverLayer.addChild(bg)

        let gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 36
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: 0, y: 70)
        gameOverLayer.addChild(gameOverLabel)

        let scoreText = SKLabelNode(text: "Coins: \(score)")
        scoreText.fontName = "AvenirNext-Medium"
        scoreText.fontSize = 24
        scoreText.fontColor = .white
        scoreText.position = CGPoint(x: 0, y: 20)
        gameOverLayer.addChild(scoreText)

        let retryButton = createMenuButton(text: "Retry", color: .orange)
        retryButton.position = CGPoint(x: 0, y: -40)
        retryButton.name = "retryButton"
        gameOverLayer.addChild(retryButton)

        let menuButton = createMenuButton(text: "Menu", color: .gray)
        menuButton.position = CGPoint(x: 0, y: -110)
        menuButton.name = "menuButton"
        gameOverLayer.addChild(menuButton)
    }

    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing, let dash = dash, let body = dash.physicsBody else { return }

        // Move Dash
        let baseSpeed: CGFloat = 300
        let speed = hasSpeedBoost ? baseSpeed * 1.5 : baseSpeed
        body.velocity.dx = moveDirection * speed

        // Update camera
        let targetX = dash.position.x
        let clampedX = max(size.width / 2, min(targetX, currentLevel.levelLength - size.width / 2))
        cameraNode.position = CGPoint(x: clampedX, y: size.height / 2)

        // Animate legs when moving
        if abs(moveDirection) > 0 {
            animateLegs()
        }

        // Animate tail
        animateTail()

        // Magnet effect - attract coins
        if hasMagnet {
            attractCoins()
        }

        // Check for fall
        if dash.position.y < -100 {
            if lives > 1 {
                lives -= 1
                PlayerData.shared.lives = lives
                livesLabel?.text = "Lives: \(lives)"
                dash.position = CGPoint(x: max(150, dash.position.x - 200), y: 300)
                body.velocity = CGVector.zero
            } else {
                lives = 0
                livesLabel?.text = "Lives: 0"
                gameOver()
            }
        }
    }

    func animateLegs() {
        guard let frontLeg = dash?.childNode(withName: "frontLeg"),
              let backLeg = dash?.childNode(withName: "backLeg") else { return }

        if frontLeg.action(forKey: "walk") == nil {
            let rotateForward = SKAction.rotate(toAngle: 0.3, duration: 0.1)
            let rotateBack = SKAction.rotate(toAngle: -0.3, duration: 0.1)
            let walkCycle = SKAction.sequence([rotateForward, rotateBack])
            frontLeg.run(SKAction.repeatForever(walkCycle), withKey: "walk")
            backLeg.run(SKAction.repeatForever(walkCycle.reversed()), withKey: "walk")
        }
    }

    func animateTail() {
        guard let tail = dash?.childNode(withName: "tail") else { return }

        if tail.action(forKey: "wag") == nil {
            let wagLeft = SKAction.rotate(toAngle: 0.2, duration: 0.2)
            let wagRight = SKAction.rotate(toAngle: -0.2, duration: 0.2)
            wagLeft.timingMode = .easeInEaseOut
            wagRight.timingMode = .easeInEaseOut
            tail.run(SKAction.repeatForever(SKAction.sequence([wagLeft, wagRight])), withKey: "wag")
        }
    }

    func attractCoins() {
        let magnetRange: CGFloat = 200

        enumerateChildNodes(withName: "coin_*") { [weak self] coin, _ in
            guard let self = self, let dash = self.dash else { return }

            let distance = hypot(coin.position.x - dash.position.x, coin.position.y - dash.position.y)

            if distance < magnetRange {
                let direction = CGVector(
                    dx: (dash.position.x - coin.position.x) / distance * 5,
                    dy: (dash.position.y - coin.position.y) / distance * 5
                )
                coin.position.x += direction.dx
                coin.position.y += direction.dy
            }
        }
    }
}
