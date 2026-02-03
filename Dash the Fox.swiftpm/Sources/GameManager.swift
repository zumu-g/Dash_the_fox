import SpriteKit

// MARK: - Game State
enum GameState {
    case menu
    case playing
    case paused
    case gameOver
    case levelComplete
    case shop
}

// MARK: - Power-up Types
enum PowerUpType: CaseIterable {
    case speedBoost
    case doubleJump
    case shield
    case magnet
    case invincibility
    case timeFreeze

    var color: SKColor {
        switch self {
        case .speedBoost: return .cyan
        case .doubleJump: return .magenta
        case .shield: return .blue
        case .magnet: return .yellow
        case .invincibility: return SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        case .timeFreeze: return SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        }
    }

    var icon: String {
        switch self {
        case .speedBoost: return "⚡"
        case .doubleJump: return "⬆"
        case .shield: return "🛡"
        case .magnet: return "◎"
        case .invincibility: return "★"
        case .timeFreeze: return "❄"
        }
    }

    var duration: TimeInterval {
        switch self {
        case .speedBoost: return 5.0
        case .doubleJump: return 10.0
        case .shield: return 8.0
        case .magnet: return 7.0
        case .invincibility: return 6.0
        case .timeFreeze: return 4.0
        }
    }
}

// MARK: - Collectible Types
enum CollectibleType {
    case coin
    case gem
    case heart
    case star

    var value: Int {
        switch self {
        case .coin: return 1
        case .gem: return 5
        case .heart: return 0
        case .star: return 10
        }
    }
}

// MARK: - Enemy Types
enum EnemyType {
    case spiky
    case slime
    case bat
    case snake
    case ghost
    case fireball
    case boss

    var speed: CGFloat {
        switch self {
        case .spiky: return 50
        case .slime: return 30
        case .bat: return 80
        case .snake: return 70
        case .ghost: return 40
        case .fireball: return 120
        case .boss: return 60
        }
    }

    var health: Int {
        switch self {
        case .boss: return 5
        default: return 1
        }
    }
}

// MARK: - Platform Types
enum PlatformType {
    case normal
    case moving
    case falling
    case bouncy
    case icy
    case crumbling
}

// MARK: - Hazard Types
enum HazardType {
    case spikes
    case lava
    case water
    case saw
}

// MARK: - Fox Skin
enum FoxSkin: String, CaseIterable {
    case classic = "Classic"
    case arctic = "Arctic"
    case shadow = "Shadow"
    case golden = "Golden"
    case cyber = "Cyber"
    case rainbow = "Rainbow"

    var price: Int {
        switch self {
        case .classic: return 0
        case .arctic: return 50
        case .shadow: return 75
        case .golden: return 150
        case .cyber: return 200
        case .rainbow: return 300
        }
    }

    var primaryColor: SKColor {
        switch self {
        case .classic: return SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        case .arctic: return SKColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
        case .shadow: return SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        case .golden: return SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
        case .cyber: return SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
        case .rainbow: return SKColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        }
    }

    var secondaryColor: SKColor {
        switch self {
        case .classic: return SKColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 1.0)
        case .arctic: return SKColor(red: 0.7, green: 0.85, blue: 0.95, alpha: 1.0)
        case .shadow: return SKColor(red: 0.4, green: 0.1, blue: 0.5, alpha: 1.0)
        case .golden: return SKColor(red: 0.9, green: 0.7, blue: 0.0, alpha: 1.0)
        case .cyber: return SKColor(red: 0.0, green: 0.5, blue: 0.8, alpha: 1.0)
        case .rainbow: return SKColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
        }
    }
}

// MARK: - Achievement
struct Achievement {
    let id: String
    let name: String
    let description: String
    let requirement: Int
    var progress: Int = 0
    var unlocked: Bool = false

    static let all: [Achievement] = [
        Achievement(id: "coins_100", name: "Coin Collector", description: "Collect 100 coins", requirement: 100),
        Achievement(id: "coins_500", name: "Treasure Hunter", description: "Collect 500 coins", requirement: 500),
        Achievement(id: "levels_3", name: "Explorer", description: "Complete 3 levels", requirement: 3),
        Achievement(id: "levels_6", name: "Adventurer", description: "Complete all 6 levels", requirement: 6),
        Achievement(id: "no_damage", name: "Untouchable", description: "Complete a level without damage", requirement: 1),
        Achievement(id: "speed_run", name: "Speed Demon", description: "Complete a level in under 60 seconds", requirement: 1),
        Achievement(id: "gems_50", name: "Gem Collector", description: "Collect 50 gems", requirement: 50),
        Achievement(id: "boss_defeat", name: "Boss Slayer", description: "Defeat a boss", requirement: 1),
        Achievement(id: "combo_10", name: "Combo Master", description: "Get a 10x coin combo", requirement: 10),
        Achievement(id: "all_skins", name: "Fashion Fox", description: "Unlock all skins", requirement: 6),
    ]
}

// MARK: - Weather Effect
enum WeatherEffect {
    case none
    case rain
    case snow
    case leaves
    case fireflies
}

// MARK: - Level Data
struct LevelData {
    let levelNumber: Int
    let name: String
    let platforms: [(x: CGFloat, y: CGFloat, width: CGFloat, type: PlatformType)]
    let coins: [CGPoint]
    let gems: [CGPoint]
    let enemies: [(position: CGPoint, type: EnemyType)]
    let powerUps: [(position: CGPoint, type: PowerUpType)]
    let hazards: [(position: CGPoint, type: HazardType, width: CGFloat)]
    let checkpoints: [CGPoint]
    let goalPosition: CGPoint
    let backgroundColors: (sky: SKColor, ground: SKColor)
    let levelLength: CGFloat
    let weather: WeatherEffect
    let hasBoss: Bool
    let bossPosition: CGPoint?
    let secretAreas: [(entrance: CGPoint, reward: CGPoint)]
    let trampolines: [CGPoint]
    let movingPlatformPaths: [[(CGPoint, CGFloat)]] // path points with duration

    static func level(_ number: Int) -> LevelData {
        switch number {
        case 1:
            return LevelData(
                levelNumber: 1,
                name: "Green Meadows",
                platforms: [
                    (300, 220, 150, .normal),
                    (550, 300, 120, .normal),
                    (800, 250, 180, .normal),
                    (1100, 350, 150, .bouncy),
                    (1400, 280, 200, .normal),
                    (1700, 400, 150, .normal),
                    (2000, 320, 180, .moving),
                    (2300, 450, 150, .normal)
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
                gems: [
                    CGPoint(x: 1100, y: 500),
                    CGPoint(x: 2000, y: 450)
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
                hazards: [],
                checkpoints: [CGPoint(x: 1200, y: 150)],
                goalPosition: CGPoint(x: 2500, y: 150),
                backgroundColors: (
                    SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0),
                    SKColor(red: 0.4, green: 0.25, blue: 0.1, alpha: 1.0)
                ),
                levelLength: 2700,
                weather: .none,
                hasBoss: false,
                bossPosition: nil,
                secretAreas: [(CGPoint(x: 850, y: 150), CGPoint(x: 850, y: -100))],
                trampolines: [CGPoint(x: 600, y: 120)],
                movingPlatformPaths: [[(CGPoint(x: 2000, y: 320), 2.0), (CGPoint(x: 2000, y: 420), 2.0)]]
            )

        case 2:
            return LevelData(
                levelNumber: 2,
                name: "Twilight Forest",
                platforms: [
                    (250, 250, 120, .normal),
                    (450, 350, 100, .falling),
                    (650, 280, 150, .normal),
                    (900, 400, 120, .icy),
                    (1150, 320, 180, .normal),
                    (1400, 450, 100, .bouncy),
                    (1650, 380, 150, .crumbling),
                    (1900, 500, 120, .normal),
                    (2150, 420, 180, .moving),
                    (2450, 550, 150, .normal),
                    (2750, 480, 200, .normal)
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
                gems: [
                    CGPoint(x: 900, y: 550),
                    CGPoint(x: 1650, y: 520),
                    CGPoint(x: 2450, y: 700)
                ],
                enemies: [
                    (CGPoint(x: 350, y: 150), .slime),
                    (CGPoint(x: 550, y: 300), .bat),
                    (CGPoint(x: 800, y: 150), .snake),
                    (CGPoint(x: 1050, y: 150), .spiky),
                    (CGPoint(x: 1300, y: 350), .bat),
                    (CGPoint(x: 1550, y: 150), .ghost),
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
                hazards: [
                    (CGPoint(x: 1000, y: 100), .spikes, 100)
                ],
                checkpoints: [CGPoint(x: 1400, y: 150), CGPoint(x: 2200, y: 150)],
                goalPosition: CGPoint(x: 3000, y: 150),
                backgroundColors: (
                    SKColor(red: 0.6, green: 0.4, blue: 0.7, alpha: 1.0),
                    SKColor(red: 0.3, green: 0.2, blue: 0.35, alpha: 1.0)
                ),
                levelLength: 3200,
                weather: .fireflies,
                hasBoss: false,
                bossPosition: nil,
                secretAreas: [(CGPoint(x: 1650, y: 150), CGPoint(x: 1650, y: -100))],
                trampolines: [CGPoint(x: 500, y: 120), CGPoint(x: 1800, y: 120)],
                movingPlatformPaths: [[(CGPoint(x: 2150, y: 420), 2.5), (CGPoint(x: 2350, y: 420), 2.5)]]
            )

        case 3:
            return LevelData(
                levelNumber: 3,
                name: "Crystal Caves",
                platforms: [
                    (200, 220, 100, .normal),
                    (380, 320, 80, .icy),
                    (560, 250, 100, .normal),
                    (750, 380, 80, .falling),
                    (950, 300, 120, .normal),
                    (1180, 420, 80, .bouncy),
                    (1400, 350, 100, .crumbling),
                    (1620, 480, 80, .normal),
                    (1850, 400, 120, .icy),
                    (2100, 520, 80, .moving),
                    (2350, 450, 100, .normal),
                    (2600, 580, 80, .falling),
                    (2850, 500, 150, .normal),
                    (3150, 620, 100, .normal)
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
                gems: [
                    CGPoint(x: 560, y: 400),
                    CGPoint(x: 1180, y: 560),
                    CGPoint(x: 2100, y: 680),
                    CGPoint(x: 2850, y: 650)
                ],
                enemies: [
                    (CGPoint(x: 280, y: 150), .snake),
                    (CGPoint(x: 470, y: 280), .bat),
                    (CGPoint(x: 650, y: 150), .spiky),
                    (CGPoint(x: 850, y: 320), .ghost),
                    (CGPoint(x: 1080, y: 150), .slime),
                    (CGPoint(x: 1290, y: 380), .bat),
                    (CGPoint(x: 1510, y: 150), .snake),
                    (CGPoint(x: 1730, y: 440), .ghost),
                    (CGPoint(x: 1970, y: 150), .spiky),
                    (CGPoint(x: 2220, y: 480), .bat),
                    (CGPoint(x: 2480, y: 150), .snake),
                    (CGPoint(x: 2720, y: 540), .bat)
                ],
                powerUps: [
                    (CGPoint(x: 450, y: 380), .doubleJump),
                    (CGPoint(x: 1050, y: 360), .shield),
                    (CGPoint(x: 1700, y: 540), .invincibility),
                    (CGPoint(x: 2200, y: 580), .magnet),
                    (CGPoint(x: 2950, y: 560), .shield)
                ],
                hazards: [
                    (CGPoint(x: 700, y: 100), .spikes, 80),
                    (CGPoint(x: 1300, y: 100), .spikes, 100),
                    (CGPoint(x: 2000, y: 100), .lava, 150)
                ],
                checkpoints: [CGPoint(x: 1000, y: 150), CGPoint(x: 2000, y: 150), CGPoint(x: 3000, y: 150)],
                goalPosition: CGPoint(x: 3400, y: 150),
                backgroundColors: (
                    SKColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0),
                    SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0)
                ),
                levelLength: 3600,
                weather: .none,
                hasBoss: false,
                bossPosition: nil,
                secretAreas: [(CGPoint(x: 1400, y: 150), CGPoint(x: 1400, y: -150))],
                trampolines: [CGPoint(x: 300, y: 120), CGPoint(x: 1500, y: 120), CGPoint(x: 2500, y: 120)],
                movingPlatformPaths: [[(CGPoint(x: 2100, y: 520), 2.0), (CGPoint(x: 2250, y: 520), 2.0)]]
            )

        case 4:
            return LevelData(
                levelNumber: 4,
                name: "Volcanic Peak",
                platforms: [
                    (200, 250, 120, .normal),
                    (400, 350, 100, .crumbling),
                    (600, 280, 130, .normal),
                    (850, 400, 100, .moving),
                    (1100, 320, 150, .normal),
                    (1350, 450, 80, .falling),
                    (1550, 380, 120, .normal),
                    (1800, 500, 100, .bouncy),
                    (2050, 420, 150, .crumbling),
                    (2300, 550, 100, .normal),
                    (2550, 480, 130, .icy),
                    (2800, 600, 120, .normal),
                    (3050, 520, 150, .moving),
                    (3300, 650, 100, .normal)
                ],
                coins: [
                    CGPoint(x: 200, y: 310), CGPoint(x: 250, y: 310),
                    CGPoint(x: 400, y: 410), CGPoint(x: 600, y: 340),
                    CGPoint(x: 650, y: 340), CGPoint(x: 850, y: 460),
                    CGPoint(x: 1100, y: 380), CGPoint(x: 1150, y: 380),
                    CGPoint(x: 1350, y: 510), CGPoint(x: 1550, y: 440),
                    CGPoint(x: 1800, y: 560), CGPoint(x: 1850, y: 560),
                    CGPoint(x: 2050, y: 480), CGPoint(x: 2300, y: 610),
                    CGPoint(x: 2550, y: 540), CGPoint(x: 2800, y: 660),
                    CGPoint(x: 3050, y: 580), CGPoint(x: 3300, y: 710)
                ],
                gems: [
                    CGPoint(x: 850, y: 550),
                    CGPoint(x: 1550, y: 520),
                    CGPoint(x: 2300, y: 700),
                    CGPoint(x: 3050, y: 680)
                ],
                enemies: [
                    (CGPoint(x: 300, y: 150), .fireball),
                    (CGPoint(x: 500, y: 300), .bat),
                    (CGPoint(x: 750, y: 150), .spiky),
                    (CGPoint(x: 950, y: 350), .fireball),
                    (CGPoint(x: 1200, y: 150), .snake),
                    (CGPoint(x: 1450, y: 400), .ghost),
                    (CGPoint(x: 1650, y: 150), .fireball),
                    (CGPoint(x: 1900, y: 450), .bat),
                    (CGPoint(x: 2150, y: 150), .spiky),
                    (CGPoint(x: 2400, y: 500), .fireball),
                    (CGPoint(x: 2650, y: 150), .ghost),
                    (CGPoint(x: 2900, y: 550), .bat),
                    (CGPoint(x: 3150, y: 150), .snake)
                ],
                powerUps: [
                    (CGPoint(x: 600, y: 400), .shield),
                    (CGPoint(x: 1100, y: 450), .invincibility),
                    (CGPoint(x: 1800, y: 650), .doubleJump),
                    (CGPoint(x: 2550, y: 620), .speedBoost),
                    (CGPoint(x: 3050, y: 700), .shield)
                ],
                hazards: [
                    (CGPoint(x: 350, y: 100), .lava, 100),
                    (CGPoint(x: 900, y: 100), .lava, 150),
                    (CGPoint(x: 1400, y: 100), .lava, 100),
                    (CGPoint(x: 2000, y: 100), .lava, 200),
                    (CGPoint(x: 2700, y: 100), .lava, 150)
                ],
                checkpoints: [CGPoint(x: 1100, y: 150), CGPoint(x: 2050, y: 150), CGPoint(x: 3050, y: 150)],
                goalPosition: CGPoint(x: 3550, y: 150),
                backgroundColors: (
                    SKColor(red: 0.6, green: 0.2, blue: 0.1, alpha: 1.0),
                    SKColor(red: 0.3, green: 0.15, blue: 0.1, alpha: 1.0)
                ),
                levelLength: 3750,
                weather: .leaves,
                hasBoss: false,
                bossPosition: nil,
                secretAreas: [(CGPoint(x: 1800, y: 150), CGPoint(x: 1800, y: -150))],
                trampolines: [CGPoint(x: 700, y: 120), CGPoint(x: 1700, y: 120), CGPoint(x: 2600, y: 120)],
                movingPlatformPaths: [
                    [(CGPoint(x: 850, y: 400), 2.0), (CGPoint(x: 1000, y: 400), 2.0)],
                    [(CGPoint(x: 3050, y: 520), 2.5), (CGPoint(x: 3050, y: 650), 2.5)]
                ]
            )

        case 5:
            return LevelData(
                levelNumber: 5,
                name: "Frozen Tundra",
                platforms: [
                    (200, 250, 150, .icy),
                    (450, 350, 120, .icy),
                    (700, 280, 100, .normal),
                    (950, 400, 130, .icy),
                    (1200, 320, 150, .falling),
                    (1450, 450, 100, .icy),
                    (1700, 380, 120, .bouncy),
                    (1950, 500, 150, .icy),
                    (2200, 420, 100, .crumbling),
                    (2450, 550, 130, .icy),
                    (2700, 480, 150, .moving),
                    (2950, 600, 120, .icy),
                    (3200, 520, 100, .normal),
                    (3450, 650, 150, .icy)
                ],
                coins: [
                    CGPoint(x: 200, y: 310), CGPoint(x: 250, y: 310), CGPoint(x: 300, y: 310),
                    CGPoint(x: 450, y: 410), CGPoint(x: 500, y: 410),
                    CGPoint(x: 700, y: 340), CGPoint(x: 950, y: 460),
                    CGPoint(x: 1000, y: 460), CGPoint(x: 1200, y: 380),
                    CGPoint(x: 1450, y: 510), CGPoint(x: 1700, y: 440),
                    CGPoint(x: 1750, y: 440), CGPoint(x: 1950, y: 560),
                    CGPoint(x: 2200, y: 480), CGPoint(x: 2450, y: 610),
                    CGPoint(x: 2700, y: 540), CGPoint(x: 2950, y: 660),
                    CGPoint(x: 3200, y: 580), CGPoint(x: 3450, y: 710)
                ],
                gems: [
                    CGPoint(x: 700, y: 420),
                    CGPoint(x: 1450, y: 600),
                    CGPoint(x: 2200, y: 580),
                    CGPoint(x: 2950, y: 750),
                    CGPoint(x: 3450, y: 800)
                ],
                enemies: [
                    (CGPoint(x: 350, y: 150), .slime),
                    (CGPoint(x: 550, y: 300), .ghost),
                    (CGPoint(x: 800, y: 150), .spiky),
                    (CGPoint(x: 1050, y: 350), .bat),
                    (CGPoint(x: 1300, y: 150), .ghost),
                    (CGPoint(x: 1550, y: 400), .slime),
                    (CGPoint(x: 1800, y: 150), .spiky),
                    (CGPoint(x: 2050, y: 450), .ghost),
                    (CGPoint(x: 2300, y: 150), .bat),
                    (CGPoint(x: 2550, y: 500), .slime),
                    (CGPoint(x: 2800, y: 150), .ghost),
                    (CGPoint(x: 3050, y: 550), .spiky),
                    (CGPoint(x: 3300, y: 150), .bat)
                ],
                powerUps: [
                    (CGPoint(x: 450, y: 480), .timeFreeze),
                    (CGPoint(x: 1200, y: 500), .shield),
                    (CGPoint(x: 1950, y: 650), .invincibility),
                    (CGPoint(x: 2700, y: 620), .magnet),
                    (CGPoint(x: 3200, y: 700), .doubleJump)
                ],
                hazards: [
                    (CGPoint(x: 600, y: 100), .water, 150),
                    (CGPoint(x: 1100, y: 100), .spikes, 100),
                    (CGPoint(x: 1600, y: 100), .water, 200),
                    (CGPoint(x: 2400, y: 100), .spikes, 150),
                    (CGPoint(x: 3100, y: 100), .water, 150)
                ],
                checkpoints: [CGPoint(x: 1200, y: 150), CGPoint(x: 2200, y: 150), CGPoint(x: 3200, y: 150)],
                goalPosition: CGPoint(x: 3700, y: 150),
                backgroundColors: (
                    SKColor(red: 0.7, green: 0.85, blue: 0.95, alpha: 1.0),
                    SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
                ),
                levelLength: 3900,
                weather: .snow,
                hasBoss: false,
                bossPosition: nil,
                secretAreas: [
                    (CGPoint(x: 950, y: 150), CGPoint(x: 950, y: -150)),
                    (CGPoint(x: 2450, y: 150), CGPoint(x: 2450, y: -150))
                ],
                trampolines: [CGPoint(x: 400, y: 120), CGPoint(x: 1500, y: 120), CGPoint(x: 2600, y: 120), CGPoint(x: 3400, y: 120)],
                movingPlatformPaths: [[(CGPoint(x: 2700, y: 480), 3.0), (CGPoint(x: 2900, y: 480), 3.0)]]
            )

        case 6:
            return LevelData(
                levelNumber: 6,
                name: "Shadow Fortress",
                platforms: [
                    (200, 250, 150, .normal),
                    (450, 350, 100, .crumbling),
                    (700, 280, 120, .moving),
                    (950, 400, 100, .falling),
                    (1200, 320, 150, .normal),
                    (1450, 450, 80, .icy),
                    (1700, 380, 120, .bouncy),
                    (1950, 500, 100, .crumbling),
                    (2200, 420, 150, .moving),
                    (2450, 550, 100, .falling),
                    (2700, 480, 120, .normal),
                    (2950, 600, 150, .icy),
                    (3200, 520, 100, .crumbling),
                    (3450, 650, 120, .normal),
                    (3700, 400, 200, .normal) // Boss arena
                ],
                coins: [
                    CGPoint(x: 200, y: 310), CGPoint(x: 250, y: 310),
                    CGPoint(x: 450, y: 410), CGPoint(x: 700, y: 340),
                    CGPoint(x: 950, y: 460), CGPoint(x: 1200, y: 380),
                    CGPoint(x: 1250, y: 380), CGPoint(x: 1450, y: 510),
                    CGPoint(x: 1700, y: 440), CGPoint(x: 1950, y: 560),
                    CGPoint(x: 2200, y: 480), CGPoint(x: 2450, y: 610),
                    CGPoint(x: 2700, y: 540), CGPoint(x: 2950, y: 660),
                    CGPoint(x: 3200, y: 580), CGPoint(x: 3450, y: 710)
                ],
                gems: [
                    CGPoint(x: 700, y: 420),
                    CGPoint(x: 1450, y: 600),
                    CGPoint(x: 2200, y: 580),
                    CGPoint(x: 2950, y: 750),
                    CGPoint(x: 3700, y: 550)
                ],
                enemies: [
                    (CGPoint(x: 350, y: 150), .ghost),
                    (CGPoint(x: 550, y: 300), .fireball),
                    (CGPoint(x: 800, y: 150), .spiky),
                    (CGPoint(x: 1050, y: 350), .ghost),
                    (CGPoint(x: 1300, y: 150), .fireball),
                    (CGPoint(x: 1550, y: 400), .bat),
                    (CGPoint(x: 1800, y: 150), .ghost),
                    (CGPoint(x: 2050, y: 450), .fireball),
                    (CGPoint(x: 2300, y: 150), .spiky),
                    (CGPoint(x: 2550, y: 500), .ghost),
                    (CGPoint(x: 2800, y: 150), .fireball),
                    (CGPoint(x: 3050, y: 550), .bat),
                    (CGPoint(x: 3300, y: 150), .ghost)
                ],
                powerUps: [
                    (CGPoint(x: 450, y: 480), .shield),
                    (CGPoint(x: 1200, y: 500), .invincibility),
                    (CGPoint(x: 1950, y: 650), .doubleJump),
                    (CGPoint(x: 2700, y: 620), .timeFreeze),
                    (CGPoint(x: 3450, y: 800), .shield)
                ],
                hazards: [
                    (CGPoint(x: 600, y: 100), .saw, 60),
                    (CGPoint(x: 1100, y: 100), .lava, 150),
                    (CGPoint(x: 1600, y: 100), .saw, 60),
                    (CGPoint(x: 2100, y: 100), .spikes, 100),
                    (CGPoint(x: 2600, y: 100), .lava, 200),
                    (CGPoint(x: 3100, y: 100), .saw, 60)
                ],
                checkpoints: [CGPoint(x: 1200, y: 150), CGPoint(x: 2200, y: 150), CGPoint(x: 3200, y: 150)],
                goalPosition: CGPoint(x: 4000, y: 150),
                backgroundColors: (
                    SKColor(red: 0.15, green: 0.1, blue: 0.2, alpha: 1.0),
                    SKColor(red: 0.1, green: 0.08, blue: 0.15, alpha: 1.0)
                ),
                levelLength: 4200,
                weather: .rain,
                hasBoss: true,
                bossPosition: CGPoint(x: 3700, y: 250),
                secretAreas: [
                    (CGPoint(x: 1700, y: 150), CGPoint(x: 1700, y: -200)),
                    (CGPoint(x: 2950, y: 150), CGPoint(x: 2950, y: -200))
                ],
                trampolines: [CGPoint(x: 500, y: 120), CGPoint(x: 1400, y: 120), CGPoint(x: 2400, y: 120), CGPoint(x: 3350, y: 120)],
                movingPlatformPaths: [
                    [(CGPoint(x: 700, y: 280), 2.0), (CGPoint(x: 850, y: 280), 2.0)],
                    [(CGPoint(x: 2200, y: 420), 2.5), (CGPoint(x: 2200, y: 550), 2.5)]
                ]
            )

        default:
            return level(1)
        }
    }

    static let totalLevels = 6
}

// MARK: - Sound Manager
class SoundManager {
    static let shared = SoundManager()
    var isMuted = false

    private init() {}

    func playJump(on node: SKNode) {
        guard !isMuted else { return }
    }

    func playCoin(on node: SKNode) {
        guard !isMuted else { return }
    }

    func playGem(on node: SKNode) {
        guard !isMuted else { return }
    }

    func playHit(on node: SKNode) {
        guard !isMuted else { return }
    }

    func playPowerUp(on node: SKNode) {
        guard !isMuted else { return }
    }

    func playBounce(on node: SKNode) {
        guard !isMuted else { return }
    }

    func playCheckpoint(on node: SKNode) {
        guard !isMuted else { return }
    }

    func playLevelComplete(on node: SKNode) {
        guard !isMuted else { return }
    }

    func playGameOver(on node: SKNode) {
        guard !isMuted else { return }
    }

    func playBossHit(on node: SKNode) {
        guard !isMuted else { return }
    }

    func playBossDefeat(on node: SKNode) {
        guard !isMuted else { return }
    }
}

// MARK: - Player Data
class PlayerData {
    static let shared = PlayerData()

    var totalCoins: Int = 0
    var totalGems: Int = 0
    var currentLevel: Int = 1
    var highScores: [Int: Int] = [:]
    var bestTimes: [Int: TimeInterval] = [:]
    var lives: Int = 3
    var maxLives: Int = 5
    var currentSkin: FoxSkin = .classic
    var unlockedSkins: [FoxSkin] = [.classic]
    var achievements: [String: Achievement] = [:]
    var totalEnemiesDefeated: Int = 0
    var totalDeaths: Int = 0
    var totalJumps: Int = 0
    var playTime: TimeInterval = 0

    private init() {
        load()
        initializeAchievements()
    }

    func initializeAchievements() {
        for achievement in Achievement.all {
            if achievements[achievement.id] == nil {
                achievements[achievement.id] = achievement
            }
        }
    }

    func save() {
        UserDefaults.standard.set(totalCoins, forKey: "totalCoins")
        UserDefaults.standard.set(totalGems, forKey: "totalGems")
        UserDefaults.standard.set(currentLevel, forKey: "currentLevel")
        UserDefaults.standard.set(lives, forKey: "lives")
        UserDefaults.standard.set(currentSkin.rawValue, forKey: "currentSkin")
        UserDefaults.standard.set(unlockedSkins.map { $0.rawValue }, forKey: "unlockedSkins")
        UserDefaults.standard.set(totalEnemiesDefeated, forKey: "totalEnemiesDefeated")
        UserDefaults.standard.set(totalDeaths, forKey: "totalDeaths")
        UserDefaults.standard.set(totalJumps, forKey: "totalJumps")
        UserDefaults.standard.set(playTime, forKey: "playTime")

        for (level, score) in highScores {
            UserDefaults.standard.set(score, forKey: "highScore_\(level)")
        }

        for (level, time) in bestTimes {
            UserDefaults.standard.set(time, forKey: "bestTime_\(level)")
        }

        // Save achievements
        for (id, achievement) in achievements {
            UserDefaults.standard.set(achievement.progress, forKey: "achievement_\(id)_progress")
            UserDefaults.standard.set(achievement.unlocked, forKey: "achievement_\(id)_unlocked")
        }
    }

    func load() {
        totalCoins = UserDefaults.standard.integer(forKey: "totalCoins")
        totalGems = UserDefaults.standard.integer(forKey: "totalGems")
        currentLevel = max(1, UserDefaults.standard.integer(forKey: "currentLevel"))
        lives = UserDefaults.standard.integer(forKey: "lives")
        if lives == 0 { lives = 3 }

        if let skinRaw = UserDefaults.standard.string(forKey: "currentSkin"),
           let skin = FoxSkin(rawValue: skinRaw) {
            currentSkin = skin
        }

        if let skinRaws = UserDefaults.standard.array(forKey: "unlockedSkins") as? [String] {
            unlockedSkins = skinRaws.compactMap { FoxSkin(rawValue: $0) }
            if !unlockedSkins.contains(.classic) {
                unlockedSkins.append(.classic)
            }
        }

        totalEnemiesDefeated = UserDefaults.standard.integer(forKey: "totalEnemiesDefeated")
        totalDeaths = UserDefaults.standard.integer(forKey: "totalDeaths")
        totalJumps = UserDefaults.standard.integer(forKey: "totalJumps")
        playTime = UserDefaults.standard.double(forKey: "playTime")

        for level in 1...LevelData.totalLevels {
            let score = UserDefaults.standard.integer(forKey: "highScore_\(level)")
            if score > 0 {
                highScores[level] = score
            }
            let time = UserDefaults.standard.double(forKey: "bestTime_\(level)")
            if time > 0 {
                bestTimes[level] = time
            }
        }

        // Load achievements
        for achievement in Achievement.all {
            var loaded = achievement
            loaded.progress = UserDefaults.standard.integer(forKey: "achievement_\(achievement.id)_progress")
            loaded.unlocked = UserDefaults.standard.bool(forKey: "achievement_\(achievement.id)_unlocked")
            achievements[achievement.id] = loaded
        }
    }

    func updateHighScore(level: Int, score: Int) {
        if score > (highScores[level] ?? 0) {
            highScores[level] = score
            save()
        }
    }

    func updateBestTime(level: Int, time: TimeInterval) {
        if bestTimes[level] == nil || time < bestTimes[level]! {
            bestTimes[level] = time
            save()
        }
    }

    func unlockSkin(_ skin: FoxSkin) -> Bool {
        guard !unlockedSkins.contains(skin) else { return false }
        guard totalCoins >= skin.price else { return false }

        totalCoins -= skin.price
        unlockedSkins.append(skin)
        save()

        checkAchievement("all_skins", progress: unlockedSkins.count)

        return true
    }

    func checkAchievement(_ id: String, progress: Int) {
        guard var achievement = achievements[id], !achievement.unlocked else { return }

        achievement.progress = max(achievement.progress, progress)
        if achievement.progress >= achievement.requirement {
            achievement.unlocked = true
        }
        achievements[id] = achievement
        save()
    }

    func addCoins(_ amount: Int) {
        totalCoins += amount
        checkAchievement("coins_100", progress: totalCoins)
        checkAchievement("coins_500", progress: totalCoins)
        save()
    }

    func addGems(_ amount: Int) {
        totalGems += amount
        checkAchievement("gems_50", progress: totalGems)
        save()
    }

    func buyLife() -> Bool {
        guard totalGems >= 5 && lives < maxLives else { return false }
        totalGems -= 5
        lives += 1
        save()
        return true
    }

    func resetProgress() {
        totalCoins = 0
        totalGems = 0
        currentLevel = 1
        highScores = [:]
        bestTimes = [:]
        lives = 3
        currentSkin = .classic
        unlockedSkins = [.classic]
        achievements = [:]
        initializeAchievements()
        totalEnemiesDefeated = 0
        totalDeaths = 0
        totalJumps = 0
        playTime = 0
        save()
    }
}
