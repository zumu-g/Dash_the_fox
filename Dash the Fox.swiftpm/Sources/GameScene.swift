//
//  GameScene.swift
//  Dash the Fox
//
//  The main game scene containing all gameplay logic:
//  - Fox character creation and physics
//  - Level generation (platforms, coins, enemies, goal)
//  - Touch controls (left, right, jump buttons)
//  - Collision detection and scoring
//  - Menu, Win, and Game Over screens
//
//  Created with Claude Code assistance.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Game state
    private var isPlaying = false
    private var score = 0
    private var lives = 3

    // Nodes
    private var dash: SKNode?
    private var cameraNode: SKCameraNode?
    private var scoreLabel: SKLabelNode?
    private var livesLabel: SKLabelNode?

    // Controls
    private var moveDirection: CGFloat = 0
    private var leftButton: SKShapeNode?
    private var rightButton: SKShapeNode?
    private var jumpButton: SKShapeNode?

    // Physics categories
    private let playerCategory: UInt32 = 1
    private let groundCategory: UInt32 = 2
    private let platformCategory: UInt32 = 4
    private let coinCategory: UInt32 = 8
    private let enemyCategory: UInt32 = 16
    private let goalCategory: UInt32 = 32

    // Level data
    private let levelLength: CGFloat = 2500

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)

        physicsWorld.gravity = CGVector(dx: 0, dy: -20)
        physicsWorld.contactDelegate = self

        setupCamera()
        showMenu()
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        if let cam = cameraNode {
            camera = cam
            addChild(cam)
        }
    }

    // MARK: - Menu
    private func showMenu() {
        isPlaying = false
        removeAllGameElements()
        cameraNode?.removeAllChildren()
        cameraNode?.position = CGPoint(x: size.width / 2, y: size.height / 2)

        // Title
        let title = SKLabelNode(text: "Dash the Fox")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 48
        title.fontColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        title.position = CGPoint(x: 0, y: 100)
        cameraNode?.addChild(title)

        // Fox preview
        let fox = createFox()
        fox.position = CGPoint(x: 0, y: 0)
        fox.setScale(1.5)
        cameraNode?.addChild(fox)

        // Play button
        let playButton = SKShapeNode(rectOf: CGSize(width: 160, height: 50), cornerRadius: 12)
        playButton.fillColor = .orange
        playButton.strokeColor = .white
        playButton.lineWidth = 3
        playButton.position = CGPoint(x: 0, y: -100)
        playButton.name = "playButton"
        cameraNode?.addChild(playButton)

        let playLabel = SKLabelNode(text: "PLAY")
        playLabel.fontName = "AvenirNext-Bold"
        playLabel.fontSize = 24
        playLabel.fontColor = .white
        playLabel.verticalAlignmentMode = .center
        playButton.addChild(playLabel)
    }

    private func startGame() {
        isPlaying = true
        score = 0
        lives = 3
        moveDirection = 0

        removeAllGameElements()
        cameraNode?.removeAllChildren()

        createLevel()
        setupControls()
        setupHUD()
    }

    private func removeAllGameElements() {
        for child in children {
            if child != cameraNode {
                child.removeFromParent()
            }
        }
    }

    // MARK: - Level Creation
    private func createLevel() {
        // Background
        createBackground()

        // Ground
        createGround()

        // Platforms
        let platforms = [
            CGPoint(x: 350, y: 220),
            CGPoint(x: 600, y: 300),
            CGPoint(x: 900, y: 250),
            CGPoint(x: 1200, y: 350),
            CGPoint(x: 1500, y: 280),
            CGPoint(x: 1800, y: 380),
            CGPoint(x: 2100, y: 320)
        ]
        for pos in platforms {
            createPlatform(at: pos)
        }

        // Coins
        let coins = [
            CGPoint(x: 350, y: 280),
            CGPoint(x: 400, y: 280),
            CGPoint(x: 600, y: 360),
            CGPoint(x: 650, y: 360),
            CGPoint(x: 900, y: 310),
            CGPoint(x: 950, y: 310),
            CGPoint(x: 1200, y: 410),
            CGPoint(x: 1500, y: 340),
            CGPoint(x: 1800, y: 440),
            CGPoint(x: 2100, y: 380)
        ]
        for (i, pos) in coins.enumerated() {
            createCoin(at: pos, index: i)
        }

        // Enemies
        let enemies = [
            CGPoint(x: 500, y: 150),
            CGPoint(x: 800, y: 150),
            CGPoint(x: 1100, y: 150),
            CGPoint(x: 1400, y: 150),
            CGPoint(x: 1700, y: 150)
        ]
        for (i, pos) in enemies.enumerated() {
            createEnemy(at: pos, index: i)
        }

        // Goal
        createGoal()

        // Player
        createPlayer()
    }

    private func createBackground() {
        // Clouds
        for i in 0..<8 {
            let cloud = SKShapeNode(ellipseOf: CGSize(width: 100, height: 50))
            cloud.fillColor = .white
            cloud.strokeColor = .clear
            cloud.alpha = 0.8
            cloud.position = CGPoint(
                x: CGFloat(i) * 350 + CGFloat.random(in: -50...50),
                y: size.height * 0.75 + CGFloat.random(in: -30...30)
            )
            cloud.zPosition = -10
            addChild(cloud)
        }

        // Hills
        for i in 0..<10 {
            let hill = SKShapeNode(ellipseOf: CGSize(width: 200, height: 120))
            hill.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0)
            hill.strokeColor = .clear
            hill.position = CGPoint(x: CGFloat(i) * 280 - 100, y: 80)
            hill.zPosition = -5
            addChild(hill)
        }
    }

    private func createGround() {
        let ground = SKSpriteNode(color: SKColor(red: 0.4, green: 0.25, blue: 0.1, alpha: 1.0),
                                   size: CGSize(width: levelLength + 400, height: 100))
        ground.position = CGPoint(x: levelLength / 2, y: 50)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.friction = 0.8
        addChild(ground)

        // Grass
        let grass = SKSpriteNode(color: SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0),
                                  size: CGSize(width: levelLength + 400, height: 15))
        grass.position = CGPoint(x: 0, y: 57)
        ground.addChild(grass)
    }

    private func createPlatform(at position: CGPoint) {
        let platform = SKSpriteNode(color: SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0),
                                     size: CGSize(width: 120, height: 25))
        platform.position = position
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = platformCategory
        platform.physicsBody?.friction = 0.8
        addChild(platform)

        // Grass top
        let grass = SKSpriteNode(color: SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0),
                                  size: CGSize(width: 120, height: 8))
        grass.position = CGPoint(x: 0, y: 16)
        platform.addChild(grass)
    }

    private func createCoin(at position: CGPoint, index: Int) {
        let coin = SKShapeNode(circleOfRadius: 12)
        coin.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
        coin.strokeColor = SKColor(red: 0.9, green: 0.7, blue: 0.0, alpha: 1.0)
        coin.lineWidth = 2
        coin.position = position
        coin.name = "coin_\(index)"
        coin.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = playerCategory
        addChild(coin)

        // Animate
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 0.5),
            SKAction.moveBy(x: 0, y: -8, duration: 0.5)
        ])
        coin.run(SKAction.repeatForever(bob))
    }

    private func createEnemy(at position: CGPoint, index: Int) {
        let enemy = SKShapeNode(circleOfRadius: 22)
        enemy.fillColor = SKColor(red: 0.4, green: 0.1, blue: 0.5, alpha: 1.0)
        enemy.strokeColor = SKColor(red: 0.6, green: 0.2, blue: 0.7, alpha: 1.0)
        enemy.lineWidth = 3
        enemy.position = position
        enemy.name = "enemy_\(index)"
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 22)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory
        addChild(enemy)

        // Eyes
        let leftEye = SKShapeNode(circleOfRadius: 5)
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -7, y: 5)
        enemy.addChild(leftEye)

        let rightEye = SKShapeNode(circleOfRadius: 5)
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 7, y: 5)
        enemy.addChild(rightEye)

        let leftPupil = SKShapeNode(circleOfRadius: 3)
        leftPupil.fillColor = .red
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: -7, y: 5)
        enemy.addChild(leftPupil)

        let rightPupil = SKShapeNode(circleOfRadius: 3)
        rightPupil.fillColor = .red
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: 7, y: 5)
        enemy.addChild(rightPupil)

        // Patrol
        let patrol = SKAction.sequence([
            SKAction.moveBy(x: 80, duration: 1.5),
            SKAction.moveBy(x: -80, duration: 1.5)
        ])
        enemy.run(SKAction.repeatForever(patrol))
    }

    private func createGoal() {
        let goal = SKNode()
        goal.position = CGPoint(x: levelLength - 100, y: 150)
        goal.name = "goal"

        // Pole
        let pole = SKShapeNode(rectOf: CGSize(width: 8, height: 120))
        pole.fillColor = SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0)
        pole.strokeColor = .clear
        pole.position = CGPoint(x: 0, y: 60)
        goal.addChild(pole)

        // Flag
        let flag = SKShapeNode(rectOf: CGSize(width: 50, height: 30))
        flag.fillColor = .red
        flag.strokeColor = .darkGray
        flag.lineWidth = 2
        flag.position = CGPoint(x: 29, y: 105)
        goal.addChild(flag)

        let star = SKLabelNode(text: "★")
        star.fontSize = 20
        star.fontColor = .yellow
        star.verticalAlignmentMode = .center
        star.position = CGPoint(x: 0, y: 0)
        flag.addChild(star)

        goal.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 120))
        goal.physicsBody?.isDynamic = false
        goal.physicsBody?.categoryBitMask = goalCategory
        goal.physicsBody?.contactTestBitMask = playerCategory

        addChild(goal)
    }

    private func createPlayer() {
        dash = createFox()
        dash?.position = CGPoint(x: 150, y: 250)
        dash?.name = "dash"

        dash?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 35, height: 45))
        dash?.physicsBody?.categoryBitMask = playerCategory
        dash?.physicsBody?.contactTestBitMask = groundCategory | platformCategory | coinCategory | enemyCategory | goalCategory
        dash?.physicsBody?.collisionBitMask = groundCategory | platformCategory
        dash?.physicsBody?.allowsRotation = false
        dash?.physicsBody?.friction = 0.2
        dash?.physicsBody?.restitution = 0

        if let d = dash {
            addChild(d)
        }
    }

    private func createFox() -> SKNode {
        let fox = SKNode()

        // Body
        let body = SKShapeNode(ellipseOf: CGSize(width: 45, height: 35))
        body.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        body.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
        body.lineWidth = 2
        fox.addChild(body)

        // Head
        let head = SKShapeNode(circleOfRadius: 18)
        head.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        head.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
        head.lineWidth = 2
        head.position = CGPoint(x: 18, y: 12)
        fox.addChild(head)

        // Ears
        let earPath = CGMutablePath()
        earPath.move(to: CGPoint(x: 0, y: 0))
        earPath.addLine(to: CGPoint(x: 6, y: 16))
        earPath.addLine(to: CGPoint(x: 12, y: 0))
        earPath.closeSubpath()

        let leftEar = SKShapeNode(path: earPath)
        leftEar.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        leftEar.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
        leftEar.position = CGPoint(x: 6, y: 25)
        fox.addChild(leftEar)

        let rightEar = SKShapeNode(path: earPath)
        rightEar.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        rightEar.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
        rightEar.position = CGPoint(x: 18, y: 25)
        fox.addChild(rightEar)

        // Snout
        let snout = SKShapeNode(ellipseOf: CGSize(width: 14, height: 10))
        snout.fillColor = .white
        snout.strokeColor = .clear
        snout.position = CGPoint(x: 28, y: 8)
        fox.addChild(snout)

        // Nose
        let nose = SKShapeNode(circleOfRadius: 3)
        nose.fillColor = .black
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 32, y: 10)
        fox.addChild(nose)

        // Eyes
        let leftEye = SKShapeNode(circleOfRadius: 4)
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: 14, y: 18)
        fox.addChild(leftEye)

        let leftPupil = SKShapeNode(circleOfRadius: 2)
        leftPupil.fillColor = .black
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: 15, y: 18)
        fox.addChild(leftPupil)

        let rightEye = SKShapeNode(circleOfRadius: 4)
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 22, y: 18)
        fox.addChild(rightEye)

        let rightPupil = SKShapeNode(circleOfRadius: 2)
        rightPupil.fillColor = .black
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: 23, y: 18)
        fox.addChild(rightPupil)

        // Tail
        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: 0, y: 0))
        tailPath.addQuadCurve(to: CGPoint(x: -35, y: 25), control: CGPoint(x: -25, y: 0))
        tailPath.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: -15, y: 18))

        let tail = SKShapeNode(path: tailPath)
        tail.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        tail.strokeColor = SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
        tail.lineWidth = 2
        tail.position = CGPoint(x: -22, y: 0)
        fox.addChild(tail)

        // Legs
        let legColor = SKColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 1.0)

        let frontLeg = SKShapeNode(rectOf: CGSize(width: 8, height: 16))
        frontLeg.fillColor = legColor
        frontLeg.strokeColor = .clear
        frontLeg.position = CGPoint(x: 12, y: -22)
        fox.addChild(frontLeg)

        let backLeg = SKShapeNode(rectOf: CGSize(width: 8, height: 16))
        backLeg.fillColor = legColor
        backLeg.strokeColor = .clear
        backLeg.position = CGPoint(x: -8, y: -22)
        fox.addChild(backLeg)

        return fox
    }

    // MARK: - Controls
    private func setupControls() {
        // Left button
        leftButton = SKShapeNode(circleOfRadius: 35)
        leftButton?.fillColor = SKColor.white.withAlphaComponent(0.3)
        leftButton?.strokeColor = SKColor.white.withAlphaComponent(0.6)
        leftButton?.lineWidth = 3
        leftButton?.name = "leftButton"
        leftButton?.zPosition = 100
        leftButton?.position = CGPoint(x: -size.width / 2 + 60, y: -size.height / 2 + 70)
        if let lb = leftButton {
            let arrow = SKLabelNode(text: "◀")
            arrow.fontSize = 28
            arrow.fontColor = .white
            arrow.verticalAlignmentMode = .center
            lb.addChild(arrow)
            cameraNode?.addChild(lb)
        }

        // Right button
        rightButton = SKShapeNode(circleOfRadius: 35)
        rightButton?.fillColor = SKColor.white.withAlphaComponent(0.3)
        rightButton?.strokeColor = SKColor.white.withAlphaComponent(0.6)
        rightButton?.lineWidth = 3
        rightButton?.name = "rightButton"
        rightButton?.zPosition = 100
        rightButton?.position = CGPoint(x: -size.width / 2 + 150, y: -size.height / 2 + 70)
        if let rb = rightButton {
            let arrow = SKLabelNode(text: "▶")
            arrow.fontSize = 28
            arrow.fontColor = .white
            arrow.verticalAlignmentMode = .center
            rb.addChild(arrow)
            cameraNode?.addChild(rb)
        }

        // Jump button
        jumpButton = SKShapeNode(circleOfRadius: 45)
        jumpButton?.fillColor = SKColor.orange.withAlphaComponent(0.4)
        jumpButton?.strokeColor = SKColor.orange.withAlphaComponent(0.8)
        jumpButton?.lineWidth = 3
        jumpButton?.name = "jumpButton"
        jumpButton?.zPosition = 100
        jumpButton?.position = CGPoint(x: size.width / 2 - 70, y: -size.height / 2 + 70)
        if let jb = jumpButton {
            let label = SKLabelNode(text: "JUMP")
            label.fontName = "AvenirNext-Bold"
            label.fontSize = 14
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            jb.addChild(label)
            cameraNode?.addChild(jb)
        }
    }

    private func setupHUD() {
        // Score
        scoreLabel = SKLabelNode(text: "Coins: 0")
        scoreLabel?.fontName = "AvenirNext-Bold"
        scoreLabel?.fontSize = 20
        scoreLabel?.fontColor = .yellow
        scoreLabel?.horizontalAlignmentMode = .left
        scoreLabel?.position = CGPoint(x: -size.width / 2 + 15, y: size.height / 2 - 35)
        scoreLabel?.zPosition = 100
        if let sl = scoreLabel {
            cameraNode?.addChild(sl)
        }

        // Lives
        livesLabel = SKLabelNode(text: "Lives: ❤️❤️❤️")
        livesLabel?.fontName = "AvenirNext-Bold"
        livesLabel?.fontSize = 20
        livesLabel?.fontColor = .white
        livesLabel?.horizontalAlignmentMode = .left
        livesLabel?.position = CGPoint(x: -size.width / 2 + 15, y: size.height / 2 - 60)
        livesLabel?.zPosition = 100
        if let ll = livesLabel {
            cameraNode?.addChild(ll)
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let cam = cameraNode else { return }
        let location = touch.location(in: cam)
        let nodes = cam.nodes(at: location)

        for node in nodes {
            let name = node.name ?? ""

            if !isPlaying && name == "playButton" {
                startGame()
                return
            }

            if isPlaying {
                if name == "leftButton" {
                    moveDirection = -1
                    dash?.xScale = -1
                } else if name == "rightButton" {
                    moveDirection = 1
                    dash?.xScale = 1
                } else if name == "jumpButton" {
                    jump()
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let cam = cameraNode else { return }
        let location = touch.location(in: cam)
        let nodes = cam.nodes(at: location)

        for node in nodes {
            let name = node.name ?? ""
            if name == "leftButton" && moveDirection < 0 {
                moveDirection = 0
            } else if name == "rightButton" && moveDirection > 0 {
                moveDirection = 0
            }
        }
    }

    private func jump() {
        guard let body = dash?.physicsBody else { return }
        if abs(body.velocity.dy) < 10 {
            body.applyImpulse(CGVector(dx: 0, dy: 380))
        }
    }

    // MARK: - Physics
    func didBegin(_ contact: SKPhysicsContact) {
        guard isPlaying else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == playerCategory | coinCategory {
            let coinNode = contact.bodyA.categoryBitMask == coinCategory ? contact.bodyA.node : contact.bodyB.node
            collectCoin(coinNode)
        }

        if collision == playerCategory | enemyCategory {
            hitEnemy()
        }

        if collision == playerCategory | goalCategory {
            win()
        }
    }

    private func collectCoin(_ coin: SKNode?) {
        guard let coin = coin else { return }
        score += 1
        scoreLabel?.text = "Coins: \(score)"

        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.15)
        let remove = SKAction.removeFromParent()
        coin.run(SKAction.sequence([scaleUp, fadeOut, remove]))
    }

    private func hitEnemy() {
        lives -= 1
        updateLivesLabel()

        // Knockback
        dash?.physicsBody?.velocity = .zero
        dash?.physicsBody?.applyImpulse(CGVector(dx: -moveDirection * 150, dy: 250))

        // Flash
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        dash?.run(SKAction.repeat(flash, count: 4))

        if lives <= 0 {
            gameOver()
        }
    }

    private func updateLivesLabel() {
        let hearts = String(repeating: "❤️", count: max(0, lives))
        livesLabel?.text = "Lives: \(hearts)"
    }

    private func win() {
        isPlaying = false

        // Victory jump
        dash?.physicsBody?.velocity = .zero
        dash?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))

        // Show win screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.showWinScreen()
        }
    }

    private func showWinScreen() {
        let bg = SKShapeNode(rectOf: CGSize(width: 280, height: 200), cornerRadius: 15)
        bg.fillColor = SKColor.black.withAlphaComponent(0.85)
        bg.strokeColor = .yellow
        bg.lineWidth = 4
        bg.position = .zero
        bg.zPosition = 200
        cameraNode?.addChild(bg)

        let winLabel = SKLabelNode(text: "YOU WIN!")
        winLabel.fontName = "AvenirNext-Bold"
        winLabel.fontSize = 32
        winLabel.fontColor = .yellow
        winLabel.position = CGPoint(x: 0, y: 50)
        bg.addChild(winLabel)

        let scoreText = SKLabelNode(text: "Coins: \(score)")
        scoreText.fontName = "AvenirNext-Medium"
        scoreText.fontSize = 22
        scoreText.fontColor = .white
        scoreText.position = CGPoint(x: 0, y: 10)
        bg.addChild(scoreText)

        let menuButton = SKShapeNode(rectOf: CGSize(width: 140, height: 45), cornerRadius: 10)
        menuButton.fillColor = .orange
        menuButton.strokeColor = .white
        menuButton.lineWidth = 2
        menuButton.position = CGPoint(x: 0, y: -50)
        menuButton.name = "menuButton"
        bg.addChild(menuButton)

        let menuLabel = SKLabelNode(text: "MENU")
        menuLabel.fontName = "AvenirNext-Bold"
        menuLabel.fontSize = 20
        menuLabel.fontColor = .white
        menuLabel.verticalAlignmentMode = .center
        menuButton.addChild(menuLabel)
    }

    private func gameOver() {
        isPlaying = false

        let bg = SKShapeNode(rectOf: CGSize(width: 280, height: 200), cornerRadius: 15)
        bg.fillColor = SKColor.black.withAlphaComponent(0.85)
        bg.strokeColor = .red
        bg.lineWidth = 4
        bg.position = .zero
        bg.zPosition = 200
        cameraNode?.addChild(bg)

        let gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 32
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: 0, y: 50)
        bg.addChild(gameOverLabel)

        let scoreText = SKLabelNode(text: "Coins: \(score)")
        scoreText.fontName = "AvenirNext-Medium"
        scoreText.fontSize = 22
        scoreText.fontColor = .white
        scoreText.position = CGPoint(x: 0, y: 10)
        bg.addChild(scoreText)

        let retryButton = SKShapeNode(rectOf: CGSize(width: 140, height: 45), cornerRadius: 10)
        retryButton.fillColor = .orange
        retryButton.strokeColor = .white
        retryButton.lineWidth = 2
        retryButton.position = CGPoint(x: 0, y: -50)
        retryButton.name = "playButton"
        bg.addChild(retryButton)

        let retryLabel = SKLabelNode(text: "RETRY")
        retryLabel.fontName = "AvenirNext-Bold"
        retryLabel.fontSize = 20
        retryLabel.fontColor = .white
        retryLabel.verticalAlignmentMode = .center
        retryButton.addChild(retryLabel)
    }

    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        guard isPlaying, let d = dash, let body = d.physicsBody, let cam = cameraNode else { return }

        // Movement
        body.velocity.dx = moveDirection * 280

        // Camera follow
        let targetX = max(size.width / 2, min(d.position.x, levelLength - size.width / 2))
        cam.position.x = targetX
        cam.position.y = size.height / 2

        // Fall check
        if d.position.y < -50 {
            lives -= 1
            updateLivesLabel()

            if lives <= 0 {
                gameOver()
            } else {
                d.position = CGPoint(x: 150, y: 250)
                body.velocity = .zero
            }
        }
    }
}
