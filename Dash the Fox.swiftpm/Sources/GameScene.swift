import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties
    var dash: SKNode!
    var ground: SKSpriteNode!
    var cameraNode: SKCameraNode!
    var goalFlag: SKNode!
    var boss: SKNode?
    var bossHealthBar: SKShapeNode?
    var bossHealth: Int = 5

    var gameState: GameState = .menu
    var currentLevel: LevelData!
    var lastCheckpoint: CGPoint?
    var levelStartTime: TimeInterval = 0
    var levelTime: TimeInterval = 0
    var damageTaken: Bool = false

    var isJumping = false
    var canDoubleJump = false
    var hasDoubleJumped = false
    var canWallJump = false
    var moveDirection: CGFloat = 0
    var score = 0
    var gemsCollected = 0
    var lives = 3
    var comboCount = 0
    var comboTimer: TimeInterval = 0
    var lastComboTime: TimeInterval = 0

    // Power-up states
    var hasSpeedBoost = false
    var hasShield = false
    var hasMagnet = false
    var hasInvincibility = false
    var hasTimeFreeze = false
    var shieldNode: SKShapeNode?

    // UI Elements
    var scoreLabel: SKLabelNode!
    var gemsLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    var levelLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var comboLabel: SKLabelNode!

    // Control buttons
    var leftButton: SKShapeNode!
    var rightButton: SKShapeNode!
    var jumpButton: SKShapeNode!

    // Menu/UI layers
    var menuLayer: SKNode!
    var gameOverLayer: SKNode!
    var levelCompleteLayer: SKNode!
    var shopLayer: SKNode!
    var pauseButton: SKShapeNode!

    // Weather particles
    var weatherEmitter: SKEmitterNode?

    // Physics categories
    let playerCategory: UInt32 = 0x1 << 0
    let groundCategory: UInt32 = 0x1 << 1
    let platformCategory: UInt32 = 0x1 << 2
    let coinCategory: UInt32 = 0x1 << 3
    let enemyCategory: UInt32 = 0x1 << 4
    let powerUpCategory: UInt32 = 0x1 << 5
    let goalCategory: UInt32 = 0x1 << 6
    let gemCategory: UInt32 = 0x1 << 7
    let hazardCategory: UInt32 = 0x1 << 8
    let trampolineCategory: UInt32 = 0x1 << 9
    let checkpointCategory: UInt32 = 0x1 << 10
    let bossCategory: UInt32 = 0x1 << 11

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
        cameraNode.removeAllChildren()

        menuLayer = SKNode()
        menuLayer.zPosition = 200
        cameraNode.addChild(menuLayer)

        // Background gradient effect
        let bgGradient = SKShapeNode(rectOf: CGSize(width: size.width + 100, height: size.height + 100))
        bgGradient.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.5)
        bgGradient.strokeColor = .clear
        bgGradient.zPosition = -1
        menuLayer.addChild(bgGradient)

        // Title with shadow
        let titleShadow = SKLabelNode(text: "Dash the Fox")
        titleShadow.fontName = "AvenirNext-Bold"
        titleShadow.fontSize = 56
        titleShadow.fontColor = .black
        titleShadow.alpha = 0.3
        titleShadow.position = CGPoint(x: 3, y: 117)
        menuLayer.addChild(titleShadow)

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
        playButton.position = CGPoint(x: 0, y: -70)
        playButton.name = "playButton"
        menuLayer.addChild(playButton)

        // Level select button
        let levelButton = createMenuButton(text: "Levels", color: .blue)
        levelButton.position = CGPoint(x: -110, y: -140)
        levelButton.name = "levelButton"
        menuLayer.addChild(levelButton)

        // Shop button
        let shopButton = createMenuButton(text: "Shop", color: .purple)
        shopButton.position = CGPoint(x: 110, y: -140)
        shopButton.name = "shopButton"
        menuLayer.addChild(shopButton)

        // Stats display
        let coinsLabel = SKLabelNode(text: "Coins: \(PlayerData.shared.totalCoins)  Gems: \(PlayerData.shared.totalGems)")
        coinsLabel.fontName = "AvenirNext-Medium"
        coinsLabel.fontSize = 20
        coinsLabel.fontColor = .yellow
        coinsLabel.position = CGPoint(x: 0, y: -210)
        menuLayer.addChild(coinsLabel)

        // Animate menu appearance
        menuLayer.alpha = 0
        menuLayer.run(SKAction.fadeIn(withDuration: 0.5))
    }

    func createMenuButton(text: String, color: SKColor) -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 180, height: 55), cornerRadius: 12)
        bg.fillColor = color
        bg.strokeColor = .white
        bg.lineWidth = 3
        button.addChild(bg)

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)

        return button
    }

    // MARK: - Shop
    func showShop() {
        gameState = .shop
        menuLayer?.removeFromParent()

        shopLayer = SKNode()
        shopLayer.zPosition = 200
        cameraNode.addChild(shopLayer)

        let bg = SKShapeNode(rectOf: CGSize(width: size.width - 40, height: size.height - 100), cornerRadius: 20)
        bg.fillColor = SKColor.black.withAlphaComponent(0.9)
        bg.strokeColor = .yellow
        bg.lineWidth = 3
        shopLayer.addChild(bg)

        let titleLabel = SKLabelNode(text: "Fox Skins Shop")
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .yellow
        titleLabel.position = CGPoint(x: 0, y: size.height / 2 - 100)
        shopLayer.addChild(titleLabel)

        let coinsLabel = SKLabelNode(text: "Your Coins: \(PlayerData.shared.totalCoins)")
        coinsLabel.fontName = "AvenirNext-Medium"
        coinsLabel.fontSize = 20
        coinsLabel.fontColor = .white
        coinsLabel.position = CGPoint(x: 0, y: size.height / 2 - 140)
        shopLayer.addChild(coinsLabel)

        // Display skins
        let skins = FoxSkin.allCases
        let columns = 3
        let startX: CGFloat = -150
        let startY: CGFloat = 50
        let spacingX: CGFloat = 150
        let spacingY: CGFloat = 140

        for (index, skin) in skins.enumerated() {
            let col = index % columns
            let row = index / columns
            let x = startX + CGFloat(col) * spacingX
            let y = startY - CGFloat(row) * spacingY

            let skinButton = createSkinButton(skin: skin)
            skinButton.position = CGPoint(x: x, y: y)
            skinButton.name = "skin_\(skin.rawValue)"
            shopLayer.addChild(skinButton)
        }

        // Back button
        let backButton = createMenuButton(text: "Back", color: .gray)
        backButton.position = CGPoint(x: 0, y: -size.height / 2 + 80)
        backButton.name = "backToMenuButton"
        shopLayer.addChild(backButton)
    }

    func createSkinButton(skin: FoxSkin) -> SKNode {
        let button = SKNode()

        let isOwned = PlayerData.shared.unlockedSkins.contains(skin)
        let isSelected = PlayerData.shared.currentSkin == skin

        let bg = SKShapeNode(rectOf: CGSize(width: 120, height: 100), cornerRadius: 10)
        bg.fillColor = isSelected ? .green.withAlphaComponent(0.3) : SKColor.gray.withAlphaComponent(0.3)
        bg.strokeColor = isSelected ? .green : (isOwned ? .white : .gray)
        bg.lineWidth = isSelected ? 4 : 2
        button.addChild(bg)

        // Mini fox preview
        let foxPreview = SKShapeNode(circleOfRadius: 20)
        foxPreview.fillColor = skin.primaryColor
        foxPreview.strokeColor = skin.secondaryColor
        foxPreview.lineWidth = 3
        foxPreview.position = CGPoint(x: 0, y: 15)
        button.addChild(foxPreview)

        let nameLabel = SKLabelNode(text: skin.rawValue)
        nameLabel.fontName = "AvenirNext-Bold"
        nameLabel.fontSize = 14
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -25)
        button.addChild(nameLabel)

        if !isOwned {
            let priceLabel = SKLabelNode(text: "\(skin.price) coins")
            priceLabel.fontName = "AvenirNext-Medium"
            priceLabel.fontSize = 12
            priceLabel.fontColor = .yellow
            priceLabel.position = CGPoint(x: 0, y: -42)
            button.addChild(priceLabel)
        } else if isSelected {
            let equippedLabel = SKLabelNode(text: "Equipped")
            equippedLabel.fontName = "AvenirNext-Medium"
            equippedLabel.fontSize = 12
            equippedLabel.fontColor = .green
            equippedLabel.position = CGPoint(x: 0, y: -42)
            button.addChild(equippedLabel)
        } else {
            let ownedLabel = SKLabelNode(text: "Owned")
            ownedLabel.fontName = "AvenirNext-Medium"
            ownedLabel.fontSize = 12
            ownedLabel.fontColor = .cyan
            ownedLabel.position = CGPoint(x: 0, y: -42)
            button.addChild(ownedLabel)
        }

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
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 180)
        levelSelectLayer.addChild(titleLabel)

        // 2 rows of 3 levels
        for i in 1...LevelData.totalLevels {
            let isUnlocked = i <= PlayerData.shared.currentLevel
            let levelButton = createLevelButton(level: i, unlocked: isUnlocked)
            let col = (i - 1) % 3
            let row = (i - 1) / 3
            levelButton.position = CGPoint(x: CGFloat(col - 1) * 130, y: 50 - CGFloat(row) * 150)
            levelButton.name = "level_\(i)"
            levelSelectLayer.addChild(levelButton)

            // Show level name
            let levelData = LevelData.level(i)
            let nameLabel = SKLabelNode(text: levelData.name)
            nameLabel.fontName = "AvenirNext-Medium"
            nameLabel.fontSize = 12
            nameLabel.fontColor = isUnlocked ? .white : .gray
            nameLabel.position = CGPoint(x: CGFloat(col - 1) * 130, y: -10 - CGFloat(row) * 150)
            levelSelectLayer.addChild(nameLabel)

            // Show best time if available
            if let bestTime = PlayerData.shared.bestTimes[i] {
                let timeLabel = SKLabelNode(text: String(format: "%.1fs", bestTime))
                timeLabel.fontName = "AvenirNext-Medium"
                timeLabel.fontSize = 11
                timeLabel.fontColor = .cyan
                timeLabel.position = CGPoint(x: CGFloat(col - 1) * 130, y: -28 - CGFloat(row) * 150)
                levelSelectLayer.addChild(timeLabel)
            }
        }

        // Back button
        let backButton = createMenuButton(text: "Back", color: .gray)
        backButton.position = CGPoint(x: 0, y: -180)
        backButton.name = "backButton"
        levelSelectLayer.addChild(backButton)
    }

    func createLevelButton(level: Int, unlocked: Bool) -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(circleOfRadius: 45)
        bg.fillColor = unlocked ? .orange : .darkGray
        bg.strokeColor = unlocked ? .white : .gray
        bg.lineWidth = 3
        button.addChild(bg)

        let label = SKLabelNode(text: unlocked ? "\(level)" : "🔒")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = unlocked ? 32 : 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)

        // Star rating based on score
        if let highScore = PlayerData.shared.highScores[level] {
            let stars = min(3, highScore / 5)
            let starLabel = SKLabelNode(text: String(repeating: "★", count: stars) + String(repeating: "☆", count: 3 - stars))
            starLabel.fontName = "AvenirNext-Bold"
            starLabel.fontSize = 14
            starLabel.fontColor = .yellow
            starLabel.position = CGPoint(x: 0, y: -60)
            button.addChild(starLabel)
        }

        return button
    }

    // MARK: - Start Game
    func startGame(level: Int) {
        gameState = .playing
        currentLevel = LevelData.level(level)
        score = 0
        gemsCollected = 0
        comboCount = 0
        hasDoubleJumped = false
        canDoubleJump = false
        hasSpeedBoost = false
        hasShield = false
        hasMagnet = false
        hasInvincibility = false
        hasTimeFreeze = false
        lastCheckpoint = nil
        damageTaken = false
        bossHealth = 5

        clearGameElements()
        menuLayer?.removeFromParent()
        shopLayer?.removeFromParent()
        cameraNode.childNode(withName: "levelSelectLayer")?.removeFromParent()
        gameOverLayer?.removeFromParent()
        levelCompleteLayer?.removeFromParent()
        cameraNode.removeAllChildren()

        backgroundColor = currentLevel.backgroundColors.sky
        levelStartTime = CACurrentMediaTime()

        setupDash()
        setupGround()
        setupPlatforms()
        setupCoins()
        setupGems()
        setupEnemies()
        setupPowerUps()
        setupHazards()
        setupTrampolines()
        setupCheckpoints()
        setupGoal()
        setupControls()
        setupHUD()
        setupBackground()
        setupPauseButton()
        setupWeather()

        if currentLevel.hasBoss, let bossPos = currentLevel.bossPosition {
            setupBoss(at: bossPos)
        }
    }

    func clearGameElements() {
        children.filter { $0 != cameraNode }.forEach { $0.removeFromParent() }
        shieldNode?.removeFromParent()
        shieldNode = nil
        weatherEmitter?.removeFromParent()
        weatherEmitter = nil
        boss = nil
        bossHealthBar = nil
    }

    // MARK: - Weather Effects
    func setupWeather() {
        switch currentLevel.weather {
        case .rain:
            createRainEffect()
        case .snow:
            createSnowEffect()
        case .leaves:
            createLeavesEffect()
        case .fireflies:
            createFirefliesEffect()
        case .none:
            break
        }
    }

    func createRainEffect() {
        let emitter = SKEmitterNode()
        emitter.particleLifetime = 2
        emitter.particleBirthRate = 200
        emitter.particleSpeed = 500
        emitter.particleSpeedRange = 100
        emitter.emissionAngle = -.pi / 2 - 0.2
        emitter.emissionAngleRange = 0.1
        emitter.particleAlpha = 0.6
        emitter.particleAlphaSpeed = -0.3
        emitter.particleScale = 0.05
        emitter.particleScaleRange = 0.02
        emitter.particleColor = .cyan

        let texture = createRainTexture()
        emitter.particleTexture = texture

        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        emitter.particlePositionRange = CGVector(dx: currentLevel.levelLength, dy: 0)
        emitter.zPosition = 50
        emitter.targetNode = self

        addChild(emitter)
        weatherEmitter = emitter
    }

    func createSnowEffect() {
        let emitter = SKEmitterNode()
        emitter.particleLifetime = 8
        emitter.particleBirthRate = 50
        emitter.particleSpeed = 50
        emitter.particleSpeedRange = 30
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = 0.5
        emitter.particleAlpha = 0.9
        emitter.particleAlphaSpeed = -0.1
        emitter.particleScale = 0.1
        emitter.particleScaleRange = 0.05
        emitter.particleColor = .white

        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        emitter.particlePositionRange = CGVector(dx: currentLevel.levelLength, dy: 0)
        emitter.zPosition = 50
        emitter.targetNode = self

        addChild(emitter)
        weatherEmitter = emitter
    }

    func createLeavesEffect() {
        let emitter = SKEmitterNode()
        emitter.particleLifetime = 6
        emitter.particleBirthRate = 10
        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 40
        emitter.emissionAngle = -.pi / 2 - 0.3
        emitter.emissionAngleRange = 0.5
        emitter.particleAlpha = 0.8
        emitter.particleRotation = 0
        emitter.particleRotationSpeed = 2
        emitter.particleScale = 0.15
        emitter.particleScaleRange = 0.05
        emitter.particleColor = SKColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0

        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        emitter.particlePositionRange = CGVector(dx: currentLevel.levelLength, dy: 0)
        emitter.zPosition = 50
        emitter.targetNode = self

        addChild(emitter)
        weatherEmitter = emitter
    }

    func createFirefliesEffect() {
        let emitter = SKEmitterNode()
        emitter.particleLifetime = 4
        emitter.particleBirthRate = 15
        emitter.particleSpeed = 20
        emitter.particleSpeedRange = 15
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        emitter.particleAlpha = 0
        emitter.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [0, 1, 1, 0], times: [0, 0.2, 0.8, 1])
        emitter.particleScale = 0.1
        emitter.particleScaleRange = 0.05
        emitter.particleColor = .yellow
        emitter.particleColorBlendFactor = 1.0

        emitter.position = CGPoint(x: size.width / 2, y: size.height / 2)
        emitter.particlePositionRange = CGVector(dx: currentLevel.levelLength, dy: size.height - 200)
        emitter.zPosition = 50
        emitter.targetNode = self

        addChild(emitter)
        weatherEmitter = emitter
    }

    func createRainTexture() -> SKTexture {
        let size = CGSize(width: 3, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }

    // MARK: - Background
    func setupBackground() {
        for i in 0..<Int(currentLevel.levelLength / 400) {
            let cloud = createCloud()
            cloud.position = CGPoint(
                x: CGFloat(i) * 400 + CGFloat.random(in: -100...100),
                y: size.height * 0.7 + CGFloat.random(in: -50...50)
            )
            cloud.zPosition = -10
            addChild(cloud)
        }

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
        case 1: hill.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0)
        case 2: hill.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.5, alpha: 1.0)
        case 3: hill.fillColor = SKColor(red: 0.2, green: 0.25, blue: 0.4, alpha: 1.0)
        case 4: hill.fillColor = SKColor(red: 0.5, green: 0.2, blue: 0.1, alpha: 1.0)
        case 5: hill.fillColor = SKColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1.0)
        case 6: hill.fillColor = SKColor(red: 0.15, green: 0.1, blue: 0.2, alpha: 1.0)
        default: hill.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0)
        }
        hill.strokeColor = .clear
        return hill
    }

    // MARK: - Dash Setup
    func setupDash() {
        dash = createFoxCharacter()
        let startPos = lastCheckpoint ?? CGPoint(x: 150, y: 300)
        dash.position = startPos
        dash.name = "dash"

        let body = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 50))
        body.categoryBitMask = playerCategory
        body.contactTestBitMask = groundCategory | platformCategory | coinCategory | enemyCategory | powerUpCategory | goalCategory | gemCategory | hazardCategory | trampolineCategory | checkpointCategory | bossCategory
        body.collisionBitMask = groundCategory | platformCategory
        body.allowsRotation = false
        body.friction = 0.2
        body.restitution = 0
        dash.physicsBody = body

        addChild(dash)
    }

    func createFoxCharacter() -> SKNode {
        let skin = PlayerData.shared.currentSkin
        let fox = SKNode()

        // Body
        let body = SKShapeNode(ellipseOf: CGSize(width: 50, height: 40))
        body.fillColor = skin.primaryColor
        body.strokeColor = skin.secondaryColor
        body.lineWidth = 2
        fox.addChild(body)

        // Head
        let head = SKShapeNode(circleOfRadius: 22)
        head.fillColor = skin.primaryColor
        head.strokeColor = skin.secondaryColor
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
        leftEar.fillColor = skin.primaryColor
        leftEar.strokeColor = skin.secondaryColor
        leftEar.position = CGPoint(x: 5, y: 30)
        fox.addChild(leftEar)

        let rightEar = SKShapeNode(path: earPath)
        rightEar.fillColor = skin.primaryColor
        rightEar.strokeColor = skin.secondaryColor
        rightEar.position = CGPoint(x: 22, y: 30)
        fox.addChild(rightEar)

        // Inner ears
        let innerEarPath = CGMutablePath()
        innerEarPath.move(to: CGPoint(x: 4, y: 2))
        innerEarPath.addLine(to: CGPoint(x: 8, y: 14))
        innerEarPath.addLine(to: CGPoint(x: 12, y: 2))
        innerEarPath.closeSubpath()

        let pinkColor = SKColor(red: 1.0, green: 0.8, blue: 0.7, alpha: 1.0)
        let leftInnerEar = SKShapeNode(path: innerEarPath)
        leftInnerEar.fillColor = pinkColor
        leftInnerEar.strokeColor = .clear
        leftInnerEar.position = CGPoint(x: 5, y: 30)
        fox.addChild(leftInnerEar)

        let rightInnerEar = SKShapeNode(path: innerEarPath)
        rightInnerEar.fillColor = pinkColor
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
        tail.fillColor = skin.primaryColor
        tail.strokeColor = skin.secondaryColor
        tail.lineWidth = 2
        tail.position = CGPoint(x: -25, y: 0)
        tail.name = "tail"
        fox.addChild(tail)

        // Tail tip
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
        let legColor = skin.secondaryColor

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

    // MARK: - Ground & Platforms
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

        let grass = SKSpriteNode(color: SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0), size: CGSize(width: groundWidth, height: 20))
        grass.position = CGPoint(x: 0, y: 60)
        ground.addChild(grass)
    }

    func setupPlatforms() {
        for (index, platformData) in currentLevel.platforms.enumerated() {
            let platform = createPlatform(width: platformData.width, type: platformData.type)
            platform.position = CGPoint(x: platformData.x, y: platformData.y)
            platform.name = "platform_\(index)"
            platform.userData = ["type": platformData.type]
            addChild(platform)

            // Setup moving platforms
            if platformData.type == .moving && index < currentLevel.movingPlatformPaths.count {
                let path = currentLevel.movingPlatformPaths[index]
                if path.count >= 2 {
                    var actions: [SKAction] = []
                    for (point, duration) in path {
                        actions.append(SKAction.move(to: point, duration: duration))
                    }
                    platform.run(SKAction.repeatForever(SKAction.sequence(actions)))
                }
            }
        }
    }

    func createPlatform(width: CGFloat, type: PlatformType) -> SKNode {
        var color: SKColor
        switch type {
        case .normal: color = SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0)
        case .bouncy: color = SKColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 1.0)
        case .icy: color = SKColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
        case .falling: color = SKColor(red: 0.6, green: 0.4, blue: 0.3, alpha: 1.0)
        case .crumbling: color = SKColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 1.0)
        case .moving: color = SKColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)
        }

        let platform = SKSpriteNode(color: color, size: CGSize(width: width, height: 30))

        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = platformCategory
        platform.physicsBody?.friction = type == .icy ? 0.01 : 0.8

        // Grass top (different for special platforms)
        var grassColor: SKColor
        switch type {
        case .bouncy: grassColor = SKColor(red: 1.0, green: 0.5, blue: 0.7, alpha: 1.0)
        case .icy: grassColor = SKColor(red: 0.8, green: 0.95, blue: 1.0, alpha: 1.0)
        default: grassColor = SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0)
        }

        let grass = SKSpriteNode(color: grassColor, size: CGSize(width: width, height: 8))
        grass.position = CGPoint(x: 0, y: 19)
        platform.addChild(grass)

        // Add indicators for special platforms
        if type == .bouncy {
            let spring = SKShapeNode(rectOf: CGSize(width: 20, height: 10))
            spring.fillColor = .yellow
            spring.strokeColor = .orange
            spring.lineWidth = 2
            spring.position = CGPoint(x: 0, y: 5)
            platform.addChild(spring)
        }

        if type == .crumbling {
            // Add crack lines
            for i in 0..<3 {
                let crack = SKShapeNode()
                let crackPath = CGMutablePath()
                crackPath.move(to: CGPoint(x: CGFloat(i - 1) * width / 4, y: -10))
                crackPath.addLine(to: CGPoint(x: CGFloat(i - 1) * width / 4 + 10, y: 10))
                crack.path = crackPath
                crack.strokeColor = .black
                crack.lineWidth = 1
                crack.alpha = 0.5
                platform.addChild(crack)
            }
        }

        return platform
    }

    // MARK: - Collectibles
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

    func setupGems() {
        for (index, pos) in currentLevel.gems.enumerated() {
            let gem = createGem()
            gem.position = pos
            gem.name = "gem_\(index)"
            addChild(gem)
        }
    }

    func createGem() -> SKNode {
        let gem = SKNode()

        // Diamond shape
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 20))
        path.addLine(to: CGPoint(x: 15, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -20))
        path.addLine(to: CGPoint(x: -15, y: 0))
        path.closeSubpath()

        let shape = SKShapeNode(path: path)
        shape.fillColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0)
        shape.strokeColor = .white
        shape.lineWidth = 2
        gem.addChild(shape)

        // Sparkle
        let sparkle = SKShapeNode(circleOfRadius: 5)
        sparkle.fillColor = .white
        sparkle.strokeColor = .clear
        sparkle.position = CGPoint(x: -5, y: 8)
        sparkle.alpha = 0.8
        gem.addChild(sparkle)

        gem.physicsBody = SKPhysicsBody(circleOfRadius: 18)
        gem.physicsBody?.isDynamic = false
        gem.physicsBody?.categoryBitMask = gemCategory
        gem.physicsBody?.contactTestBitMask = playerCategory

        // Sparkle animation
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.5)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        sparkle.run(SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn])))

        // Float animation
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.8)
        let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 0.8)
        moveUp.timingMode = .easeInEaseOut
        moveDown.timingMode = .easeInEaseOut
        gem.run(SKAction.repeatForever(SKAction.sequence([moveUp, moveDown])))

        return gem
    }

    // MARK: - Enemies
    func setupEnemies() {
        for (index, enemyData) in currentLevel.enemies.enumerated() {
            let enemy = createEnemy(type: enemyData.type)
            enemy.position = enemyData.position
            enemy.name = "enemy_\(index)"
            addChild(enemy)

            switch enemyData.type {
            case .spiky, .slime, .snake:
                let moveRight = SKAction.moveBy(x: 100, duration: 2)
                let moveLeft = SKAction.moveBy(x: -100, duration: 2)
                enemy.run(SKAction.repeatForever(SKAction.sequence([moveRight, moveLeft])))
            case .bat, .ghost:
                let moveRight = SKAction.moveBy(x: 80, duration: 1.5)
                let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 0.75)
                let moveDown = SKAction.moveBy(x: 0, y: -40, duration: 0.75)
                let moveLeft = SKAction.moveBy(x: -80, duration: 1.5)
                enemy.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.group([moveRight, SKAction.sequence([moveUp, moveDown])]),
                    SKAction.group([moveLeft, SKAction.sequence([moveUp, moveDown])])
                ])))
            case .fireball:
                let moveRight = SKAction.moveBy(x: 150, duration: 1.0)
                let moveLeft = SKAction.moveBy(x: -150, duration: 1.0)
                enemy.run(SKAction.repeatForever(SKAction.sequence([moveRight, moveLeft])))
            case .boss:
                break
            }
        }
    }

    func createEnemy(type: EnemyType) -> SKNode {
        switch type {
        case .spiky: return createSpikyEnemy()
        case .slime: return createSlimeEnemy()
        case .bat: return createBatEnemy()
        case .snake: return createSnakeEnemy()
        case .ghost: return createGhostEnemy()
        case .fireball: return createFireballEnemy()
        case .boss: return createBossEnemy()
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

        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 3)
        enemy.run(SKAction.repeatForever(rotate))

        return enemy
    }

    func createSlimeEnemy() -> SKNode {
        let enemy = SKNode()
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

        let squish = SKAction.scaleY(to: 0.7, duration: 0.3)
        let stretch = SKAction.scaleY(to: 1.2, duration: 0.3)
        let normal = SKAction.scaleY(to: 1.0, duration: 0.2)
        enemy.run(SKAction.repeatForever(SKAction.sequence([squish, stretch, normal])))

        return enemy
    }

    func createBatEnemy() -> SKNode {
        let enemy = SKNode()
        let body = SKShapeNode(ellipseOf: CGSize(width: 30, height: 25))
        body.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        body.strokeColor = .clear
        enemy.addChild(body)

        let wingPath = CGMutablePath()
        wingPath.move(to: CGPoint(x: 0, y: 0))
        wingPath.addQuadCurve(to: CGPoint(x: 35, y: -10), control: CGPoint(x: 20, y: 15))
        wingPath.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: 15, y: -5))

        let leftWing = SKShapeNode(path: wingPath)
        leftWing.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.4, alpha: 1.0)
        leftWing.strokeColor = .clear
        leftWing.position = CGPoint(x: -15, y: 5)
        enemy.addChild(leftWing)

        let rightWing = SKShapeNode(path: wingPath)
        rightWing.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.4, alpha: 1.0)
        rightWing.strokeColor = .clear
        rightWing.xScale = -1
        rightWing.position = CGPoint(x: 15, y: 5)
        enemy.addChild(rightWing)

        addEnemyEyes(to: enemy, color: .yellow, size: 4)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory

        let flapUp = SKAction.rotate(toAngle: 0.5, duration: 0.15)
        let flapDown = SKAction.rotate(toAngle: -0.3, duration: 0.15)
        let wingFlap = SKAction.repeatForever(SKAction.sequence([flapUp, flapDown]))
        leftWing.run(wingFlap)
        rightWing.run(wingFlap.reversed())

        return enemy
    }

    func createSnakeEnemy() -> SKNode {
        let enemy = SKNode()
        let segmentColor = SKColor(red: 0.6, green: 0.4, blue: 0.1, alpha: 1.0)

        for i in 0..<5 {
            let segment = SKShapeNode(circleOfRadius: CGFloat(12 - i))
            segment.fillColor = segmentColor
            segment.strokeColor = SKColor(red: 0.5, green: 0.3, blue: 0.0, alpha: 1.0)
            segment.lineWidth = 2
            segment.position = CGPoint(x: CGFloat(-i * 12), y: 0)
            enemy.addChild(segment)
        }

        let head = SKShapeNode(ellipseOf: CGSize(width: 28, height: 20))
        head.fillColor = segmentColor
        head.strokeColor = SKColor(red: 0.5, green: 0.3, blue: 0.0, alpha: 1.0)
        head.lineWidth = 2
        head.position = CGPoint(x: 20, y: 0)
        enemy.addChild(head)

        let eye = SKShapeNode(circleOfRadius: 4)
        eye.fillColor = .yellow
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 25, y: 5)
        enemy.addChild(eye)

        let tongue = SKShapeNode(rectOf: CGSize(width: 15, height: 3))
        tongue.fillColor = .red
        tongue.strokeColor = .clear
        tongue.position = CGPoint(x: 38, y: 0)
        enemy.addChild(tongue)

        let tongueOut = SKAction.moveBy(x: 8, y: 0, duration: 0.2)
        let tongueIn = SKAction.moveBy(x: -8, y: 0, duration: 0.2)
        tongue.run(SKAction.repeatForever(SKAction.sequence([tongueOut, tongueIn, SKAction.wait(forDuration: 1.0)])))

        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 24))
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory

        return enemy
    }

    func createGhostEnemy() -> SKNode {
        let enemy = SKNode()

        let path = CGMutablePath()
        path.move(to: CGPoint(x: -20, y: -20))
        path.addQuadCurve(to: CGPoint(x: 0, y: 25), control: CGPoint(x: -25, y: 10))
        path.addQuadCurve(to: CGPoint(x: 20, y: -20), control: CGPoint(x: 25, y: 10))
        path.addQuadCurve(to: CGPoint(x: 10, y: -15), control: CGPoint(x: 15, y: -25))
        path.addQuadCurve(to: CGPoint(x: 0, y: -20), control: CGPoint(x: 5, y: -10))
        path.addQuadCurve(to: CGPoint(x: -10, y: -15), control: CGPoint(x: -5, y: -10))
        path.addQuadCurve(to: CGPoint(x: -20, y: -20), control: CGPoint(x: -15, y: -25))

        let body = SKShapeNode(path: path)
        body.fillColor = SKColor.white.withAlphaComponent(0.7)
        body.strokeColor = SKColor.white.withAlphaComponent(0.9)
        body.lineWidth = 2
        enemy.addChild(body)

        let leftEye = SKShapeNode(ellipseOf: CGSize(width: 10, height: 14))
        leftEye.fillColor = .black
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -8, y: 5)
        enemy.addChild(leftEye)

        let rightEye = SKShapeNode(ellipseOf: CGSize(width: 10, height: 14))
        rightEye.fillColor = .black
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 8, y: 5)
        enemy.addChild(rightEye)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 22)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory

        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 1.0)
        let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 1.0)
        enemy.run(SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn])))

        return enemy
    }

    func createFireballEnemy() -> SKNode {
        let enemy = SKNode()

        let core = SKShapeNode(circleOfRadius: 15)
        core.fillColor = .yellow
        core.strokeColor = .orange
        core.lineWidth = 3
        enemy.addChild(core)

        let outerFlame = SKShapeNode(circleOfRadius: 22)
        outerFlame.fillColor = SKColor.orange.withAlphaComponent(0.5)
        outerFlame.strokeColor = .clear
        enemy.addChild(outerFlame)

        let pulse = SKAction.scale(to: 1.3, duration: 0.2)
        let shrink = SKAction.scale(to: 0.9, duration: 0.2)
        outerFlame.run(SKAction.repeatForever(SKAction.sequence([pulse, shrink])))

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 18)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory

        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
        enemy.run(SKAction.repeatForever(rotate))

        return enemy
    }

    func createBossEnemy() -> SKNode {
        let enemy = SKNode()

        let body = SKShapeNode(circleOfRadius: 60)
        body.fillColor = SKColor(red: 0.3, green: 0.0, blue: 0.0, alpha: 1.0)
        body.strokeColor = SKColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0)
        body.lineWidth = 5
        enemy.addChild(body)

        // Horns
        let hornPath = CGMutablePath()
        hornPath.move(to: CGPoint(x: 0, y: 0))
        hornPath.addLine(to: CGPoint(x: 10, y: 40))
        hornPath.addLine(to: CGPoint(x: 20, y: 0))

        let leftHorn = SKShapeNode(path: hornPath)
        leftHorn.fillColor = .darkGray
        leftHorn.strokeColor = .black
        leftHorn.position = CGPoint(x: -40, y: 40)
        leftHorn.zRotation = -0.3
        enemy.addChild(leftHorn)

        let rightHorn = SKShapeNode(path: hornPath)
        rightHorn.fillColor = .darkGray
        rightHorn.strokeColor = .black
        rightHorn.position = CGPoint(x: 20, y: 40)
        rightHorn.zRotation = 0.3
        enemy.addChild(rightHorn)

        // Eyes
        let leftEye = SKShapeNode(circleOfRadius: 12)
        leftEye.fillColor = .yellow
        leftEye.strokeColor = .red
        leftEye.lineWidth = 2
        leftEye.position = CGPoint(x: -25, y: 15)
        enemy.addChild(leftEye)

        let rightEye = SKShapeNode(circleOfRadius: 12)
        rightEye.fillColor = .yellow
        rightEye.strokeColor = .red
        rightEye.lineWidth = 2
        rightEye.position = CGPoint(x: 25, y: 15)
        enemy.addChild(rightEye)

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 60)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = bossCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory

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

    // MARK: - Boss
    func setupBoss(at position: CGPoint) {
        boss = createBossEnemy()
        boss?.position = position
        boss?.name = "boss"
        addChild(boss!)

        // Boss health bar
        bossHealthBar = SKShapeNode(rectOf: CGSize(width: 100, height: 10), cornerRadius: 5)
        bossHealthBar?.fillColor = .red
        bossHealthBar?.strokeColor = .white
        bossHealthBar?.lineWidth = 2
        bossHealthBar?.position = CGPoint(x: position.x, y: position.y + 100)
        bossHealthBar?.zPosition = 100
        addChild(bossHealthBar!)

        // Boss movement
        let moveLeft = SKAction.moveBy(x: -100, y: 0, duration: 2)
        let moveRight = SKAction.moveBy(x: 100, y: 0, duration: 2)
        let jump = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        let fall = SKAction.moveBy(x: 0, y: -50, duration: 0.5)
        let pattern = SKAction.sequence([moveLeft, SKAction.sequence([jump, fall]), moveRight, SKAction.sequence([jump, fall])])
        boss?.run(SKAction.repeatForever(pattern))
    }

    func hitBoss() {
        bossHealth -= 1

        // Update health bar
        let healthPercent = CGFloat(bossHealth) / 5.0
        bossHealthBar?.xScale = healthPercent

        // Flash effect
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
        ])
        boss?.run(SKAction.repeat(flash, count: 3))

        if bossHealth <= 0 {
            defeatBoss()
        }
    }

    func defeatBoss() {
        PlayerData.shared.checkAchievement("boss_defeat", progress: 1)

        // Explosion effect
        for _ in 0..<20 {
            let particle = SKShapeNode(circleOfRadius: 10)
            particle.fillColor = [.red, .orange, .yellow].randomElement()!
            particle.strokeColor = .clear
            particle.position = boss?.position ?? .zero
            particle.zPosition = 100
            addChild(particle)

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let distance = CGFloat.random(in: 50...150)
            let move = SKAction.moveBy(x: cos(angle) * distance, y: sin(angle) * distance, duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            particle.run(SKAction.sequence([SKAction.group([move, fade]), SKAction.removeFromParent()]))
        }

        boss?.removeFromParent()
        bossHealthBar?.removeFromParent()
        boss = nil
    }

    // MARK: - Hazards
    func setupHazards() {
        for (index, hazardData) in currentLevel.hazards.enumerated() {
            let hazard = createHazard(type: hazardData.type, width: hazardData.width)
            hazard.position = hazardData.position
            hazard.name = "hazard_\(index)"
            addChild(hazard)
        }
    }

    func createHazard(type: HazardType, width: CGFloat) -> SKNode {
        let hazard = SKNode()

        switch type {
        case .spikes:
            let spikeCount = Int(width / 20)
            for i in 0..<spikeCount {
                let spike = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: CGPoint(x: -10, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 25))
                path.addLine(to: CGPoint(x: 10, y: 0))
                path.closeSubpath()
                spike.path = path
                spike.fillColor = .gray
                spike.strokeColor = .darkGray
                spike.lineWidth = 2
                spike.position = CGPoint(x: CGFloat(i) * 20 - width / 2 + 10, y: 0)
                hazard.addChild(spike)
            }

        case .lava:
            let lava = SKShapeNode(rectOf: CGSize(width: width, height: 30))
            lava.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0)
            lava.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
            lava.lineWidth = 3
            hazard.addChild(lava)

            // Bubble animation
            let bubble = SKShapeNode(circleOfRadius: 5)
            bubble.fillColor = .orange
            bubble.strokeColor = .clear
            bubble.position = CGPoint(x: 0, y: 10)
            hazard.addChild(bubble)

            let rise = SKAction.moveBy(x: 0, y: 15, duration: 0.5)
            let pop = SKAction.scale(to: 0, duration: 0.1)
            let reset = SKAction.group([SKAction.scale(to: 1, duration: 0), SKAction.moveTo(y: 10, duration: 0)])
            bubble.run(SKAction.repeatForever(SKAction.sequence([rise, pop, reset])))

        case .water:
            let water = SKShapeNode(rectOf: CGSize(width: width, height: 40))
            water.fillColor = SKColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 0.7)
            water.strokeColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
            water.lineWidth = 2
            hazard.addChild(water)

        case .saw:
            let saw = SKShapeNode(circleOfRadius: width / 2)
            saw.fillColor = .gray
            saw.strokeColor = .darkGray
            saw.lineWidth = 3
            hazard.addChild(saw)

            // Teeth
            let teethCount = 12
            for i in 0..<teethCount {
                let angle = CGFloat(i) * (.pi * 2 / CGFloat(teethCount))
                let tooth = SKShapeNode(rectOf: CGSize(width: 8, height: 15))
                tooth.fillColor = .gray
                tooth.strokeColor = .darkGray
                tooth.position = CGPoint(x: cos(angle) * (width / 2 + 5), y: sin(angle) * (width / 2 + 5))
                tooth.zRotation = angle
                hazard.addChild(tooth)
            }

            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 1)
            hazard.run(SKAction.repeatForever(rotate))
        }

        hazard.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: 30))
        hazard.physicsBody?.isDynamic = false
        hazard.physicsBody?.categoryBitMask = hazardCategory
        hazard.physicsBody?.contactTestBitMask = playerCategory

        return hazard
    }

    // MARK: - Trampolines
    func setupTrampolines() {
        for (index, pos) in currentLevel.trampolines.enumerated() {
            let trampoline = createTrampoline()
            trampoline.position = pos
            trampoline.name = "trampoline_\(index)"
            addChild(trampoline)
        }
    }

    func createTrampoline() -> SKNode {
        let trampoline = SKNode()

        // Base
        let base = SKShapeNode(rectOf: CGSize(width: 60, height: 15), cornerRadius: 3)
        base.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
        base.strokeColor = .gray
        base.lineWidth = 2
        trampoline.addChild(base)

        // Bounce pad
        let pad = SKShapeNode(rectOf: CGSize(width: 50, height: 8), cornerRadius: 4)
        pad.fillColor = .red
        pad.strokeColor = .darkGray
        pad.lineWidth = 2
        pad.position = CGPoint(x: 0, y: 12)
        pad.name = "bouncePad"
        trampoline.addChild(pad)

        trampoline.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 25))
        trampoline.physicsBody?.isDynamic = false
        trampoline.physicsBody?.categoryBitMask = trampolineCategory
        trampoline.physicsBody?.contactTestBitMask = playerCategory

        return trampoline
    }

    // MARK: - Checkpoints
    func setupCheckpoints() {
        for (index, pos) in currentLevel.checkpoints.enumerated() {
            let checkpoint = createCheckpoint()
            checkpoint.position = pos
            checkpoint.name = "checkpoint_\(index)"
            addChild(checkpoint)
        }
    }

    func createCheckpoint() -> SKNode {
        let checkpoint = SKNode()

        // Flag pole
        let pole = SKShapeNode(rectOf: CGSize(width: 6, height: 80))
        pole.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0)
        pole.strokeColor = .clear
        pole.position = CGPoint(x: 0, y: 40)
        checkpoint.addChild(pole)

        // Flag
        let flag = SKShapeNode(rectOf: CGSize(width: 30, height: 20))
        flag.fillColor = .white
        flag.strokeColor = .gray
        flag.lineWidth = 2
        flag.position = CGPoint(x: 18, y: 70)
        flag.name = "checkpointFlag"
        checkpoint.addChild(flag)

        checkpoint.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 80), center: CGPoint(x: 0, y: 40))
        checkpoint.physicsBody?.isDynamic = false
        checkpoint.physicsBody?.categoryBitMask = checkpointCategory
        checkpoint.physicsBody?.contactTestBitMask = playerCategory

        return checkpoint
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

        let glow = SKShapeNode(circleOfRadius: 25)
        glow.fillColor = type.color.withAlphaComponent(0.3)
        glow.strokeColor = .clear
        powerUp.addChild(glow)

        let pulseOut = SKAction.scale(to: 1.3, duration: 0.5)
        let pulseIn = SKAction.scale(to: 1.0, duration: 0.5)
        glow.run(SKAction.repeatForever(SKAction.sequence([pulseOut, pulseIn])))

        let body = SKShapeNode(circleOfRadius: 18)
        body.fillColor = type.color
        body.strokeColor = .white
        body.lineWidth = 3
        powerUp.addChild(body)

        let icon = SKLabelNode(text: type.icon)
        icon.fontSize = 18
        icon.verticalAlignmentMode = .center
        powerUp.addChild(icon)

        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: 18)
        powerUp.physicsBody?.isDynamic = false
        powerUp.physicsBody?.categoryBitMask = powerUpCategory
        powerUp.physicsBody?.contactTestBitMask = playerCategory

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

        let pole = SKShapeNode(rectOf: CGSize(width: 8, height: 150))
        pole.fillColor = SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0)
        pole.strokeColor = .clear
        pole.position = CGPoint(x: 0, y: 75)
        goal.addChild(pole)

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
        goal.addChild(flag)

        let star = SKLabelNode(text: "★")
        star.fontName = "AvenirNext-Bold"
        star.fontSize = 24
        star.fontColor = .yellow
        star.position = CGPoint(x: 25, y: -25)
        flag.addChild(star)

        let waveRight = SKAction.rotate(toAngle: 0.1, duration: 0.5)
        let waveLeft = SKAction.rotate(toAngle: -0.05, duration: 0.5)
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

        let leftArrow = SKLabelNode(text: "◀")
        leftArrow.fontSize = 30
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

        let rightArrow = SKLabelNode(text: "▶")
        rightArrow.fontSize = 30
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
        jumpLabel.fontSize = 16
        jumpLabel.fontColor = .white
        jumpLabel.verticalAlignmentMode = .center
        jumpButton.addChild(jumpLabel)

        updateControlPositions()
    }

    func setupPauseButton() {
        pauseButton = SKShapeNode(rectOf: CGSize(width: 45, height: 45), cornerRadius: 8)
        pauseButton.fillColor = SKColor.black.withAlphaComponent(0.3)
        pauseButton.strokeColor = .white
        pauseButton.lineWidth = 2
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 100
        pauseButton.position = CGPoint(x: size.width / 2 - 35, y: size.height / 2 - 35)
        cameraNode.addChild(pauseButton)

        let pauseIcon = SKLabelNode(text: "| |")
        pauseIcon.fontName = "AvenirNext-Bold"
        pauseIcon.fontSize = 20
        pauseIcon.fontColor = .white
        pauseIcon.verticalAlignmentMode = .center
        pauseButton.addChild(pauseIcon)
    }

    func updateControlPositions() {
        let bottomY = -size.height / 2 + 70
        leftButton?.position = CGPoint(x: -size.width / 2 + 60, y: bottomY)
        rightButton?.position = CGPoint(x: -size.width / 2 + 160, y: bottomY)
        jumpButton?.position = CGPoint(x: size.width / 2 - 70, y: bottomY)
    }

    // MARK: - HUD
    func setupHUD() {
        scoreLabel = SKLabelNode(text: "Coins: 0")
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .yellow
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: -size.width / 2 + 15, y: size.height / 2 - 30)
        scoreLabel.zPosition = 100
        cameraNode.addChild(scoreLabel)

        gemsLabel = SKLabelNode(text: "Gems: 0")
        gemsLabel.fontName = "AvenirNext-Bold"
        gemsLabel.fontSize = 20
        gemsLabel.fontColor = .cyan
        gemsLabel.horizontalAlignmentMode = .left
        gemsLabel.position = CGPoint(x: -size.width / 2 + 15, y: size.height / 2 - 55)
        gemsLabel.zPosition = 100
        cameraNode.addChild(gemsLabel)

        livesLabel = SKLabelNode(text: "❤️ x\(lives)")
        livesLabel.fontName = "AvenirNext-Bold"
        livesLabel.fontSize = 20
        livesLabel.fontColor = .red
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.position = CGPoint(x: -size.width / 2 + 15, y: size.height / 2 - 80)
        livesLabel.zPosition = 100
        cameraNode.addChild(livesLabel)

        levelLabel = SKLabelNode(text: currentLevel.name)
        levelLabel.fontName = "AvenirNext-Bold"
        levelLabel.fontSize = 20
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: 0, y: size.height / 2 - 30)
        levelLabel.zPosition = 100
        cameraNode.addChild(levelLabel)

        timerLabel = SKLabelNode(text: "0.0s")
        timerLabel.fontName = "AvenirNext-Medium"
        timerLabel.fontSize = 18
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: 0, y: size.height / 2 - 55)
        timerLabel.zPosition = 100
        cameraNode.addChild(timerLabel)

        comboLabel = SKLabelNode(text: "")
        comboLabel.fontName = "AvenirNext-Bold"
        comboLabel.fontSize = 24
        comboLabel.fontColor = .orange
        comboLabel.position = CGPoint(x: 0, y: 0)
        comboLabel.zPosition = 100
        comboLabel.alpha = 0
        cameraNode.addChild(comboLabel)
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

            if gameState == .menu {
                if began {
                    if nodeName == "playButton" {
                        startGame(level: PlayerData.shared.currentLevel)
                        return
                    }
                    if nodeName == "levelButton" {
                        showLevelSelect()
                        return
                    }
                    if nodeName == "shopButton" {
                        showShop()
                        return
                    }
                }
            }

            if gameState == .shop {
                if began {
                    if nodeName == "backToMenuButton" {
                        shopLayer?.removeFromParent()
                        showMainMenu()
                        return
                    }
                    if nodeName.hasPrefix("skin_") {
                        let skinName = nodeName.replacingOccurrences(of: "skin_", with: "")
                        if let skin = FoxSkin(rawValue: skinName) {
                            handleSkinSelection(skin)
                        }
                        return
                    }
                }
            }

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

            if began && nodeName == "pauseButton" {
                togglePause()
                return
            }

            if gameState == .playing {
                if nodeName == "leftButton" {
                    if began {
                        moveDirection = -1
                        flipDash(facingRight: false)
                    } else if moveDirection < 0 {
                        moveDirection = 0
                    }
                } else if nodeName == "rightButton" {
                    if began {
                        moveDirection = 1
                        flipDash(facingRight: true)
                    } else if moveDirection > 0 {
                        moveDirection = 0
                    }
                } else if nodeName == "jumpButton" && began {
                    jump()
                }
            }
        }
    }

    func handleSkinSelection(_ skin: FoxSkin) {
        if PlayerData.shared.unlockedSkins.contains(skin) {
            PlayerData.shared.currentSkin = skin
            PlayerData.shared.save()
        } else {
            if PlayerData.shared.unlockSkin(skin) {
                // Success
            }
        }
        // Refresh shop
        shopLayer?.removeFromParent()
        showShop()
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

        let bg = SKShapeNode(rectOf: CGSize(width: 280, height: 220), cornerRadius: 15)
        bg.fillColor = SKColor.black.withAlphaComponent(0.85)
        bg.strokeColor = .white
        bg.lineWidth = 3
        pauseMenu.addChild(bg)

        let pauseLabel = SKLabelNode(text: "PAUSED")
        pauseLabel.fontName = "AvenirNext-Bold"
        pauseLabel.fontSize = 32
        pauseLabel.fontColor = .white
        pauseLabel.position = CGPoint(x: 0, y: 55)
        pauseMenu.addChild(pauseLabel)

        let resumeButton = createMenuButton(text: "Resume", color: .green)
        resumeButton.position = CGPoint(x: 0, y: 0)
        resumeButton.name = "pauseButton"
        pauseMenu.addChild(resumeButton)

        let menuButton = createMenuButton(text: "Menu", color: .gray)
        menuButton.position = CGPoint(x: 0, y: -65)
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
            PlayerData.shared.totalJumps += 1
            playJumpEffect()
        } else if canDoubleJump && !hasDoubleJumped {
            body.velocity.dy = 0
            body.applyImpulse(CGVector(dx: 0, dy: 400))
            hasDoubleJumped = true
            PlayerData.shared.totalJumps += 1
            playJumpEffect()

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

        if collision == playerCategory | gemCategory {
            let gemNode = contact.bodyA.categoryBitMask == gemCategory ? contact.bodyA.node : contact.bodyB.node
            collectGem(gemNode)
        }

        if collision == playerCategory | enemyCategory {
            if !hasShield && !hasInvincibility {
                hitEnemy()
            } else if hasShield {
                removeShield()
            }
        }

        if collision == playerCategory | bossCategory {
            if !hasShield && !hasInvincibility {
                hitEnemy()
            } else {
                hitBoss()
                if hasShield { removeShield() }
            }
        }

        if collision == playerCategory | powerUpCategory {
            let powerUpNode = contact.bodyA.categoryBitMask == powerUpCategory ? contact.bodyA.node : contact.bodyB.node
            collectPowerUp(powerUpNode)
        }

        if collision == playerCategory | hazardCategory {
            if !hasShield && !hasInvincibility {
                hitEnemy()
            } else if hasShield {
                removeShield()
            }
        }

        if collision == playerCategory | trampolineCategory {
            bounce()
        }

        if collision == playerCategory | checkpointCategory {
            let checkpointNode = contact.bodyA.categoryBitMask == checkpointCategory ? contact.bodyA.node : contact.bodyB.node
            activateCheckpoint(checkpointNode)
        }

        if collision == playerCategory | goalCategory {
            reachGoal()
        }

        // Platform interactions
        if collision == playerCategory | platformCategory {
            let platformNode = contact.bodyA.categoryBitMask == platformCategory ? contact.bodyA.node : contact.bodyB.node
            handlePlatformContact(platformNode)
        }
    }

    func handlePlatformContact(_ platform: SKNode?) {
        guard let platform = platform, let userData = platform.userData,
              let type = userData["type"] as? PlatformType else { return }

        switch type {
        case .bouncy:
            dash?.physicsBody?.velocity.dy = 0
            dash?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 600))
        case .falling:
            let wait = SKAction.wait(forDuration: 0.5)
            let shake = SKAction.sequence([
                SKAction.moveBy(x: 2, y: 0, duration: 0.05),
                SKAction.moveBy(x: -4, y: 0, duration: 0.05),
                SKAction.moveBy(x: 2, y: 0, duration: 0.05)
            ])
            let fall = SKAction.moveBy(x: 0, y: -500, duration: 1.0)
            let remove = SKAction.removeFromParent()
            platform.run(SKAction.sequence([wait, SKAction.repeat(shake, count: 5), fall, remove]))
        case .crumbling:
            let wait = SKAction.wait(forDuration: 1.0)
            let crumble = SKAction.run {
                for _ in 0..<5 {
                    let piece = SKShapeNode(rectOf: CGSize(width: 15, height: 15))
                    piece.fillColor = platform.children.first?.children.first is SKSpriteNode ?
                        (platform.children.first as? SKSpriteNode)?.color ?? .brown : .brown
                    piece.strokeColor = .clear
                    piece.position = CGPoint(
                        x: platform.position.x + CGFloat.random(in: -30...30),
                        y: platform.position.y
                    )
                    piece.zPosition = 5
                    self.addChild(piece)

                    let fall = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: -200, duration: 0.5)
                    let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
                    let fade = SKAction.fadeOut(withDuration: 0.5)
                    piece.run(SKAction.sequence([SKAction.group([fall, rotate, fade]), SKAction.removeFromParent()]))
                }
            }
            let remove = SKAction.removeFromParent()
            platform.run(SKAction.sequence([wait, crumble, remove]))
        default:
            break
        }
    }

    func bounce() {
        dash?.physicsBody?.velocity.dy = 0
        dash?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 700))

        let squish = SKAction.scaleY(to: 0.6, duration: 0.1)
        let stretch = SKAction.scaleY(to: 1.2, duration: 0.15)
        let normal = SKAction.scaleY(to: 1.0, duration: 0.1)
        dash?.run(SKAction.sequence([squish, stretch, normal]))
    }

    func activateCheckpoint(_ checkpoint: SKNode?) {
        guard let checkpoint = checkpoint else { return }

        lastCheckpoint = checkpoint.position

        // Change flag color
        if let flag = checkpoint.childNode(withName: "checkpointFlag") as? SKShapeNode {
            flag.fillColor = .green
        }

        // Effect
        let ring = SKShapeNode(circleOfRadius: 30)
        ring.fillColor = .clear
        ring.strokeColor = .green
        ring.lineWidth = 3
        ring.position = checkpoint.position
        ring.zPosition = 50
        addChild(ring)

        let expand = SKAction.scale(to: 3, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        ring.run(SKAction.sequence([SKAction.group([expand, fade]), SKAction.removeFromParent()]))
    }

    func collectCoin(_ coin: SKNode?) {
        guard let coin = coin else { return }

        // Combo system
        let currentTime = CACurrentMediaTime()
        if currentTime - lastComboTime < 1.0 {
            comboCount += 1
            PlayerData.shared.checkAchievement("combo_10", progress: comboCount)
        } else {
            comboCount = 1
        }
        lastComboTime = currentTime

        let coinValue = comboCount > 1 ? comboCount : 1
        score += coinValue
        PlayerData.shared.addCoins(coinValue)
        scoreLabel?.text = "Coins: \(score)"

        // Show combo
        if comboCount > 1 {
            comboLabel?.text = "\(comboCount)x COMBO!"
            comboLabel?.alpha = 1
            comboLabel?.setScale(0.5)
            let grow = SKAction.scale(to: 1.2, duration: 0.2)
            let shrink = SKAction.scale(to: 1.0, duration: 0.1)
            let wait = SKAction.wait(forDuration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            comboLabel?.run(SKAction.sequence([grow, shrink, wait, fadeOut]))
        }

        coin.run(SKAction.sequence([
            SKAction.group([SKAction.scale(to: 1.5, duration: 0.1), SKAction.fadeOut(withDuration: 0.2)]),
            SKAction.removeFromParent()
        ]))

        showScorePopup(at: coin.position, text: "+\(coinValue)", color: .yellow)
    }

    func collectGem(_ gem: SKNode?) {
        guard let gem = gem else { return }

        gemsCollected += 1
        PlayerData.shared.addGems(1)
        gemsLabel?.text = "Gems: \(gemsCollected)"

        gem.run(SKAction.sequence([
            SKAction.group([SKAction.scale(to: 1.5, duration: 0.1), SKAction.fadeOut(withDuration: 0.2)]),
            SKAction.removeFromParent()
        ]))

        showScorePopup(at: gem.position, text: "+1 GEM", color: .cyan)
    }

    func showScorePopup(at position: CGPoint, text: String, color: SKColor) {
        let popup = SKLabelNode(text: text)
        popup.fontName = "AvenirNext-Bold"
        popup.fontSize = 20
        popup.fontColor = color
        popup.position = position
        popup.zPosition = 50
        addChild(popup)

        let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        popup.run(SKAction.sequence([SKAction.group([moveUp, fade]), SKAction.removeFromParent()]))
    }

    func collectPowerUp(_ powerUp: SKNode?) {
        guard let powerUp = powerUp, let userData = powerUp.userData,
              let type = userData["type"] as? PowerUpType else { return }

        switch type {
        case .speedBoost: activateSpeedBoost()
        case .doubleJump: activateDoubleJump()
        case .shield: activateShield()
        case .magnet: activateMagnet()
        case .invincibility: activateInvincibility()
        case .timeFreeze: activateTimeFreeze()
        }

        let burst = SKShapeNode(circleOfRadius: 30)
        burst.fillColor = type.color.withAlphaComponent(0.5)
        burst.strokeColor = type.color
        burst.lineWidth = 3
        burst.position = powerUp.position
        burst.zPosition = 50
        addChild(burst)

        burst.run(SKAction.sequence([
            SKAction.group([SKAction.scale(to: 3, duration: 0.3), SKAction.fadeOut(withDuration: 0.3)]),
            SKAction.removeFromParent()
        ]))

        powerUp.removeFromParent()
    }

    func activateSpeedBoost() {
        hasSpeedBoost = true
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
        shieldNode?.removeFromParent()
        shieldNode = SKShapeNode(circleOfRadius: 45)
        shieldNode?.fillColor = SKColor.blue.withAlphaComponent(0.2)
        shieldNode?.strokeColor = .cyan
        shieldNode?.lineWidth = 3
        shieldNode?.zPosition = 10
        dash?.addChild(shieldNode!)

        run(SKAction.sequence([
            SKAction.wait(forDuration: PowerUpType.shield.duration),
            SKAction.run { [weak self] in self?.removeShield() }
        ]), withKey: "shield")
    }

    func removeShield() {
        hasShield = false
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

    func activateInvincibility() {
        hasInvincibility = true

        // Rainbow flash effect
        let colors: [SKColor] = [.red, .orange, .yellow, .green, .blue, .purple]
        var colorActions: [SKAction] = []
        for color in colors {
            colorActions.append(SKAction.run { [weak self] in
                self?.dash?.children.compactMap { $0 as? SKShapeNode }.forEach { shape in
                    if shape.name != "frontLeg" && shape.name != "backLeg" {
                        shape.strokeColor = color
                    }
                }
            })
            colorActions.append(SKAction.wait(forDuration: 0.1))
        }
        dash?.run(SKAction.repeat(SKAction.sequence(colorActions), count: Int(PowerUpType.invincibility.duration / 0.6)), withKey: "invincibleFlash")

        run(SKAction.sequence([
            SKAction.wait(forDuration: PowerUpType.invincibility.duration),
            SKAction.run { [weak self] in
                self?.hasInvincibility = false
                self?.dash?.removeAction(forKey: "invincibleFlash")
            }
        ]), withKey: "invincibility")
    }

    func activateTimeFreeze() {
        hasTimeFreeze = true

        // Slow down enemies
        enumerateChildNodes(withName: "enemy_*") { enemy, _ in
            enemy.speed = 0.2
        }

        // Visual effect
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 2, height: size.height * 2))
        overlay.fillColor = SKColor.cyan.withAlphaComponent(0.1)
        overlay.strokeColor = .clear
        overlay.zPosition = 40
        overlay.name = "freezeOverlay"
        cameraNode.addChild(overlay)

        run(SKAction.sequence([
            SKAction.wait(forDuration: PowerUpType.timeFreeze.duration),
            SKAction.run { [weak self] in
                self?.hasTimeFreeze = false
                self?.enumerateChildNodes(withName: "enemy_*") { enemy, _ in
                    enemy.speed = 1.0
                }
                self?.cameraNode.childNode(withName: "freezeOverlay")?.removeFromParent()
            }
        ]), withKey: "timeFreeze")
    }

    func hitEnemy() {
        damageTaken = true
        lives -= 1
        PlayerData.shared.lives = lives
        PlayerData.shared.totalDeaths += 1
        livesLabel?.text = "❤️ x\(lives)"

        // Knockback
        let knockback = CGVector(dx: -moveDirection * 200, dy: 300)
        dash?.physicsBody?.velocity = .zero
        dash?.physicsBody?.applyImpulse(knockback)

        // Flash effect
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        dash?.run(SKAction.repeat(flash, count: 5))

        if lives <= 0 {
            gameOver()
        }
    }

    func reachGoal() {
        guard gameState == .playing else { return }
        gameState = .levelComplete

        levelTime = CACurrentMediaTime() - levelStartTime

        PlayerData.shared.updateHighScore(level: currentLevel.levelNumber, score: score)
        PlayerData.shared.updateBestTime(level: currentLevel.levelNumber, time: levelTime)

        if currentLevel.levelNumber >= PlayerData.shared.currentLevel {
            PlayerData.shared.currentLevel = min(currentLevel.levelNumber + 1, LevelData.totalLevels)
        }

        PlayerData.shared.checkAchievement("levels_3", progress: PlayerData.shared.currentLevel)
        PlayerData.shared.checkAchievement("levels_6", progress: PlayerData.shared.currentLevel)

        if !damageTaken {
            PlayerData.shared.checkAchievement("no_damage", progress: 1)
        }

        if levelTime < 60 {
            PlayerData.shared.checkAchievement("speed_run", progress: 1)
        }

        PlayerData.shared.save()

        let jump1 = SKAction.moveBy(x: 0, y: 50, duration: 0.3)
        let jump2 = SKAction.moveBy(x: 0, y: -50, duration: 0.3)
        dash?.run(SKAction.sequence([jump1, jump2, jump1, jump2]))

        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.run { [weak self] in self?.showLevelComplete() }
        ]))
    }

    func showLevelComplete() {
        levelCompleteLayer = SKNode()
        levelCompleteLayer.zPosition = 200
        cameraNode.addChild(levelCompleteLayer)

        let bg = SKShapeNode(rectOf: CGSize(width: 320, height: 350), cornerRadius: 15)
        bg.fillColor = SKColor.black.withAlphaComponent(0.85)
        bg.strokeColor = .yellow
        bg.lineWidth = 4
        levelCompleteLayer.addChild(bg)

        let completeLabel = SKLabelNode(text: "LEVEL COMPLETE!")
        completeLabel.fontName = "AvenirNext-Bold"
        completeLabel.fontSize = 28
        completeLabel.fontColor = .yellow
        completeLabel.position = CGPoint(x: 0, y: 120)
        levelCompleteLayer.addChild(completeLabel)

        let timeLabel = SKLabelNode(text: String(format: "Time: %.1fs", levelTime))
        timeLabel.fontName = "AvenirNext-Medium"
        timeLabel.fontSize = 20
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: 0, y: 80)
        levelCompleteLayer.addChild(timeLabel)

        let scoreText = SKLabelNode(text: "Coins: \(score)")
        scoreText.fontName = "AvenirNext-Medium"
        scoreText.fontSize = 20
        scoreText.fontColor = .yellow
        scoreText.position = CGPoint(x: 0, y: 50)
        levelCompleteLayer.addChild(scoreText)

        let gemsText = SKLabelNode(text: "Gems: \(gemsCollected)")
        gemsText.fontName = "AvenirNext-Medium"
        gemsText.fontSize = 20
        gemsText.fontColor = .cyan
        gemsText.position = CGPoint(x: 0, y: 20)
        levelCompleteLayer.addChild(gemsText)

        if currentLevel.levelNumber < LevelData.totalLevels {
            let nextButton = createMenuButton(text: "Next Level", color: .green)
            nextButton.position = CGPoint(x: 0, y: -40)
            nextButton.name = "nextButton"
            levelCompleteLayer.addChild(nextButton)
        }

        let menuButton = createMenuButton(text: "Menu", color: .gray)
        menuButton.position = CGPoint(x: 0, y: -110)
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

        let bg = SKShapeNode(rectOf: CGSize(width: 320, height: 260), cornerRadius: 15)
        bg.fillColor = SKColor.black.withAlphaComponent(0.85)
        bg.strokeColor = .red
        bg.lineWidth = 4
        gameOverLayer.addChild(bg)

        let gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 32
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: 0, y: 70)
        gameOverLayer.addChild(gameOverLabel)

        let scoreText = SKLabelNode(text: "Coins: \(score)")
        scoreText.fontName = "AvenirNext-Medium"
        scoreText.fontSize = 22
        scoreText.fontColor = .white
        scoreText.position = CGPoint(x: 0, y: 25)
        gameOverLayer.addChild(scoreText)

        let retryButton = createMenuButton(text: "Retry", color: .orange)
        retryButton.position = CGPoint(x: 0, y: -30)
        retryButton.name = "retryButton"
        gameOverLayer.addChild(retryButton)

        let menuButton = createMenuButton(text: "Menu", color: .gray)
        menuButton.position = CGPoint(x: 0, y: -95)
        menuButton.name = "menuButton"
        gameOverLayer.addChild(menuButton)
    }

    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing, let dash = dash, let body = dash.physicsBody else { return }

        // Update timer
        levelTime = currentTime - levelStartTime
        timerLabel?.text = String(format: "%.1fs", levelTime)

        // Move Dash
        let baseSpeed: CGFloat = 300
        let speed = hasSpeedBoost ? baseSpeed * 1.5 : baseSpeed
        body.velocity.dx = moveDirection * speed

        // Update camera
        let targetX = dash.position.x
        let clampedX = max(size.width / 2, min(targetX, currentLevel.levelLength - size.width / 2))
        cameraNode.position = CGPoint(x: clampedX, y: size.height / 2)

        // Animations
        if abs(moveDirection) > 0 {
            animateLegs()
        }
        animateTail()

        // Magnet effect
        if hasMagnet {
            attractCollectibles()
        }

        // Check for fall
        if dash.position.y < -100 {
            if let checkpoint = lastCheckpoint {
                dash.position = CGPoint(x: checkpoint.x, y: checkpoint.y + 100)
                body.velocity = .zero
                lives -= 1
                PlayerData.shared.lives = lives
                livesLabel?.text = "❤️ x\(lives)"
                if lives <= 0 {
                    gameOver()
                }
            } else {
                lives -= 1
                PlayerData.shared.lives = lives
                livesLabel?.text = "❤️ x\(lives)"
                dash.position = CGPoint(x: 150, y: 300)
                body.velocity = .zero
                if lives <= 0 {
                    gameOver()
                }
            }
        }
    }

    func animateLegs() {
        guard let frontLeg = dash?.childNode(withName: "frontLeg"),
              let backLeg = dash?.childNode(withName: "backLeg") else { return }

        if frontLeg.action(forKey: "walk") == nil {
            let forward = SKAction.rotate(toAngle: 0.3, duration: 0.1)
            let back = SKAction.rotate(toAngle: -0.3, duration: 0.1)
            let cycle = SKAction.sequence([forward, back])
            frontLeg.run(SKAction.repeatForever(cycle), withKey: "walk")
            backLeg.run(SKAction.repeatForever(cycle.reversed()), withKey: "walk")
        }
    }

    func animateTail() {
        guard let tail = dash?.childNode(withName: "tail") else { return }

        if tail.action(forKey: "wag") == nil {
            let left = SKAction.rotate(toAngle: 0.2, duration: 0.2)
            let right = SKAction.rotate(toAngle: -0.2, duration: 0.2)
            left.timingMode = .easeInEaseOut
            right.timingMode = .easeInEaseOut
            tail.run(SKAction.repeatForever(SKAction.sequence([left, right])), withKey: "wag")
        }
    }

    func attractCollectibles() {
        let magnetRange: CGFloat = 200

        enumerateChildNodes(withName: "coin_*") { [weak self] coin, _ in
            guard let self = self, let dash = self.dash else { return }
            let distance = hypot(coin.position.x - dash.position.x, coin.position.y - dash.position.y)
            if distance < magnetRange && distance > 0 {
                let direction = CGVector(
                    dx: (dash.position.x - coin.position.x) / distance * 8,
                    dy: (dash.position.y - coin.position.y) / distance * 8
                )
                coin.position.x += direction.dx
                coin.position.y += direction.dy
            }
        }

        enumerateChildNodes(withName: "gem_*") { [weak self] gem, _ in
            guard let self = self, let dash = self.dash else { return }
            let distance = hypot(gem.position.x - dash.position.x, gem.position.y - dash.position.y)
            if distance < magnetRange && distance > 0 {
                let direction = CGVector(
                    dx: (dash.position.x - gem.position.x) / distance * 8,
                    dy: (dash.position.y - gem.position.y) / distance * 8
                )
                gem.position.x += direction.dx
                gem.position.y += direction.dy
            }
        }
    }
}
