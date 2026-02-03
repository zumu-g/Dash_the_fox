import SpriteKit

// MARK: - Game State
enum GameState {
    case menu
    case playing
    case paused
    case gameOver
    case levelComplete
}

// MARK: - Power-up Types
enum PowerUpType: CaseIterable {
    case speedBoost
    case doubleJump
    case shield
    case magnet

    var color: SKColor {
        switch self {
        case .speedBoost: return .cyan
        case .doubleJump: return .magenta
        case .shield: return .blue
        case .magnet: return .yellow
        }
    }

    var icon: String {
        switch self {
        case .speedBoost: return ">"
        case .doubleJump: return "^"
        case .shield: return "O"
        case .magnet: return "M"
        }
    }

    var duration: TimeInterval {
        switch self {
        case .speedBoost: return 5.0
        case .doubleJump: return 10.0
        case .shield: return 8.0
        case .magnet: return 7.0
        }
    }
}

// MARK: - Enemy Types
enum EnemyType {
    case spiky      // Original purple spiky ball
    case slime      // Bouncing green slime
    case bat        // Flying bat
    case snake      // Ground snake

    var speed: CGFloat {
        switch self {
        case .spiky: return 50
        case .slime: return 30
        case .bat: return 80
        case .snake: return 70
        }
    }
}

// MARK: - Level Data
struct LevelData {
    let levelNumber: Int
    let platforms: [(x: CGFloat, y: CGFloat, width: CGFloat)]
    let coins: [CGPoint]
    let enemies: [(position: CGPoint, type: EnemyType)]
    let powerUps: [(position: CGPoint, type: PowerUpType)]
    let goalPosition: CGPoint
    let backgroundColors: (sky: SKColor, ground: SKColor)
    let levelLength: CGFloat

    static func level(_ number: Int) -> LevelData {
        switch number {
        case 1:
            return LevelData(
                levelNumber: 1,
                platforms: [
                    (300, 220, 150),
                    (550, 300, 120),
                    (800, 250, 180),
                    (1100, 350, 150),
                    (1400, 280, 200),
                    (1700, 400, 150),
                    (2000, 320, 180),
                    (2300, 450, 150)
                ],
                coins: [
                    CGPoint(x: 300, y: 280), CGPoint(x: 350, y: 280),
                    CGPoint(x: 550, y: 360), CGPoint(x: 600, y: 360),
                    CGPoint(x: 800, y: 310), CGPoint(x: 850, y: 310),
                    CGPoint(x: 1100, y: 410), CGPoint(x: 1150, y: 410),
                    CGPoint(x: 1400, y: 340), CGPoint(x: 1450, y: 340),
                    CGPoint(x: 1700, y: 460), CGPoint(x: 2000, y: 380),
                    CGPoint(x: 2300, y: 510)
                ],
                enemies: [
                    (CGPoint(x: 450, y: 150), .spiky),
                    (CGPoint(x: 700, y: 150), .slime),
                    (CGPoint(x: 1000, y: 150), .spiky),
                    (CGPoint(x: 1250, y: 150), .slime),
                    (CGPoint(x: 1600, y: 150), .spiky)
                ],
                powerUps: [
                    (CGPoint(x: 900, y: 310), .speedBoost),
                    (CGPoint(x: 1500, y: 340), .doubleJump)
                ],
                goalPosition: CGPoint(x: 2500, y: 150),
                backgroundColors: (
                    SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0),
                    SKColor(red: 0.4, green: 0.25, blue: 0.1, alpha: 1.0)
                ),
                levelLength: 2700
            )

        case 2:
            return LevelData(
                levelNumber: 2,
                platforms: [
                    (250, 250, 120),
                    (450, 350, 100),
                    (650, 280, 150),
                    (900, 400, 120),
                    (1150, 320, 180),
                    (1400, 450, 100),
                    (1650, 380, 150),
                    (1900, 500, 120),
                    (2150, 420, 180),
                    (2450, 550, 150),
                    (2750, 480, 200)
                ],
                coins: [
                    CGPoint(x: 250, y: 310), CGPoint(x: 300, y: 310),
                    CGPoint(x: 450, y: 410), CGPoint(x: 500, y: 410),
                    CGPoint(x: 650, y: 340), CGPoint(x: 700, y: 340),
                    CGPoint(x: 900, y: 460), CGPoint(x: 950, y: 460),
                    CGPoint(x: 1150, y: 380), CGPoint(x: 1200, y: 380),
                    CGPoint(x: 1400, y: 510), CGPoint(x: 1650, y: 440),
                    CGPoint(x: 1900, y: 560), CGPoint(x: 2150, y: 480),
                    CGPoint(x: 2450, y: 610), CGPoint(x: 2750, y: 540)
                ],
                enemies: [
                    (CGPoint(x: 350, y: 150), .slime),
                    (CGPoint(x: 550, y: 300), .bat),
                    (CGPoint(x: 800, y: 150), .snake),
                    (CGPoint(x: 1050, y: 150), .spiky),
                    (CGPoint(x: 1300, y: 350), .bat),
                    (CGPoint(x: 1550, y: 150), .snake),
                    (CGPoint(x: 1800, y: 400), .bat),
                    (CGPoint(x: 2050, y: 150), .spiky),
                    (CGPoint(x: 2350, y: 150), .slime)
                ],
                powerUps: [
                    (CGPoint(x: 750, y: 340), .shield),
                    (CGPoint(x: 1250, y: 380), .speedBoost),
                    (CGPoint(x: 1750, y: 440), .magnet),
                    (CGPoint(x: 2250, y: 480), .doubleJump)
                ],
                goalPosition: CGPoint(x: 3000, y: 150),
                backgroundColors: (
                    SKColor(red: 0.6, green: 0.4, blue: 0.7, alpha: 1.0),
                    SKColor(red: 0.3, green: 0.2, blue: 0.35, alpha: 1.0)
                ),
                levelLength: 3200
            )

        case 3:
            return LevelData(
                levelNumber: 3,
                platforms: [
                    (200, 220, 100),
                    (380, 320, 80),
                    (560, 250, 100),
                    (750, 380, 80),
                    (950, 300, 120),
                    (1180, 420, 80),
                    (1400, 350, 100),
                    (1620, 480, 80),
                    (1850, 400, 120),
                    (2100, 520, 80),
                    (2350, 450, 100),
                    (2600, 580, 80),
                    (2850, 500, 150),
                    (3150, 620, 100)
                ],
                coins: [
                    CGPoint(x: 200, y: 280), CGPoint(x: 380, y: 380),
                    CGPoint(x: 560, y: 310), CGPoint(x: 750, y: 440),
                    CGPoint(x: 950, y: 360), CGPoint(x: 1000, y: 360),
                    CGPoint(x: 1180, y: 480), CGPoint(x: 1400, y: 410),
                    CGPoint(x: 1620, y: 540), CGPoint(x: 1850, y: 460),
                    CGPoint(x: 2100, y: 580), CGPoint(x: 2350, y: 510),
                    CGPoint(x: 2600, y: 640), CGPoint(x: 2850, y: 560),
                    CGPoint(x: 2900, y: 560), CGPoint(x: 3150, y: 680)
                ],
                enemies: [
                    (CGPoint(x: 280, y: 150), .snake),
                    (CGPoint(x: 470, y: 280), .bat),
                    (CGPoint(x: 650, y: 150), .spiky),
                    (CGPoint(x: 850, y: 320), .bat),
                    (CGPoint(x: 1080, y: 150), .slime),
                    (CGPoint(x: 1290, y: 380), .bat),
                    (CGPoint(x: 1510, y: 150), .snake),
                    (CGPoint(x: 1730, y: 440), .bat),
                    (CGPoint(x: 1970, y: 150), .spiky),
                    (CGPoint(x: 2220, y: 480), .bat),
                    (CGPoint(x: 2480, y: 150), .snake),
                    (CGPoint(x: 2720, y: 540), .bat)
                ],
                powerUps: [
                    (CGPoint(x: 450, y: 380), .doubleJump),
                    (CGPoint(x: 1050, y: 360), .shield),
                    (CGPoint(x: 1700, y: 540), .speedBoost),
                    (CGPoint(x: 2200, y: 580), .magnet),
                    (CGPoint(x: 2950, y: 560), .shield)
                ],
                goalPosition: CGPoint(x: 3400, y: 150),
                backgroundColors: (
                    SKColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0),
                    SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0)
                ),
                levelLength: 3600
            )

        default:
            return level(1)
        }
    }

    static let totalLevels = 3
}

// MARK: - Sound Manager
class SoundManager {
    static let shared = SoundManager()

    private var sounds: [String: SKAction] = [:]

    private init() {
        preloadSounds()
    }

    private func preloadSounds() {
        // We'll create synthesized sounds since we can't include audio files
    }

    func playJump(on node: SKNode) {
        let jumpSound = createJumpSound()
        node.run(jumpSound)
    }

    func playCoin(on node: SKNode) {
        let coinSound = createCoinSound()
        node.run(coinSound)
    }

    func playHit(on node: SKNode) {
        let hitSound = createHitSound()
        node.run(hitSound)
    }

    func playPowerUp(on node: SKNode) {
        let powerUpSound = createPowerUpSound()
        node.run(powerUpSound)
    }

    func playLevelComplete(on node: SKNode) {
        let completeSound = createLevelCompleteSound()
        node.run(completeSound)
    }

    func playGameOver(on node: SKNode) {
        let gameOverSound = createGameOverSound()
        node.run(gameOverSound)
    }

    // Synthesized sound effects using SKAction
    private func createJumpSound() -> SKAction {
        return SKAction.playSoundFileNamed("", waitForCompletion: false)
    }

    private func createCoinSound() -> SKAction {
        return SKAction.playSoundFileNamed("", waitForCompletion: false)
    }

    private func createHitSound() -> SKAction {
        return SKAction.playSoundFileNamed("", waitForCompletion: false)
    }

    private func createPowerUpSound() -> SKAction {
        return SKAction.playSoundFileNamed("", waitForCompletion: false)
    }

    private func createLevelCompleteSound() -> SKAction {
        return SKAction.playSoundFileNamed("", waitForCompletion: false)
    }

    private func createGameOverSound() -> SKAction {
        return SKAction.playSoundFileNamed("", waitForCompletion: false)
    }
}

// MARK: - Player Data
class PlayerData {
    static let shared = PlayerData()

    var totalCoins: Int = 0
    var currentLevel: Int = 1
    var highScores: [Int: Int] = [:]  // level: score
    var lives: Int = 3

    private init() {
        load()
    }

    func save() {
        UserDefaults.standard.set(totalCoins, forKey: "totalCoins")
        UserDefaults.standard.set(currentLevel, forKey: "currentLevel")
        UserDefaults.standard.set(lives, forKey: "lives")

        // Save high scores
        for (level, score) in highScores {
            UserDefaults.standard.set(score, forKey: "highScore_\(level)")
        }
    }

    func load() {
        totalCoins = UserDefaults.standard.integer(forKey: "totalCoins")
        currentLevel = max(1, UserDefaults.standard.integer(forKey: "currentLevel"))
        lives = UserDefaults.standard.integer(forKey: "lives")
        if lives == 0 { lives = 3 }

        // Load high scores
        for level in 1...LevelData.totalLevels {
            let score = UserDefaults.standard.integer(forKey: "highScore_\(level)")
            if score > 0 {
                highScores[level] = score
            }
        }
    }

    func updateHighScore(level: Int, score: Int) {
        if score > (highScores[level] ?? 0) {
            highScores[level] = score
            save()
        }
    }

    func resetProgress() {
        totalCoins = 0
        currentLevel = 1
        highScores = [:]
        lives = 3
        save()
    }
}
