import UIKit

struct LevelPalette {
    let background: [UIColor]
    let planetInner: UIColor
    let planetOuter: UIColor
    let fire: UIColor
    let ice: UIColor
    let accent: UIColor
}

struct LevelDifficulty {
    let startingLives: Int
    let baseRotationSpeed: CGFloat
    let rotationAcceleration: CGFloat
    let maxRotationSpeed: CGFloat
    let baseAsteroidSpeed: CGFloat
    let asteroidSpeedAcceleration: CGFloat
    let baseSpawnInterval: TimeInterval
    let minSpawnInterval: TimeInterval
    let spawnTightening: TimeInterval
}

struct LevelConfiguration {
    let id: Int
    let name: String
    let subtitle: String
    let palette: LevelPalette
    let difficulty: LevelDifficulty
}

enum LevelCatalog {

    static let levels: [LevelConfiguration] = [
        LevelConfiguration(
            id: 1,
            name: "Aurora Watch",
            subtitle: "A calm orbit to learn the swing",
            palette: LevelPalette(
                background: [UIColor(red: 0.04, green: 0.07, blue: 0.18, alpha: 1), UIColor(red: 0.02, green: 0.03, blue: 0.08, alpha: 1)],
                planetInner: UIColor(red: 0.20, green: 0.55, blue: 0.95, alpha: 1),
                planetOuter: UIColor(red: 0.05, green: 0.20, blue: 0.45, alpha: 1),
                fire: UIColor(red: 1.00, green: 0.45, blue: 0.20, alpha: 1),
                ice: UIColor(red: 0.40, green: 0.80, blue: 1.00, alpha: 1),
                accent: UIColor(red: 0.55, green: 0.85, blue: 1.00, alpha: 1)
            ),
            difficulty: LevelDifficulty(
                startingLives: 4,
                baseRotationSpeed: 1.6,
                rotationAcceleration: 0.05,
                maxRotationSpeed: 6.0,
                baseAsteroidSpeed: 78,
                asteroidSpeedAcceleration: 1.8,
                baseSpawnInterval: 2.2,
                minSpawnInterval: 0.7,
                spawnTightening: 0.03
            )
        ),
        LevelConfiguration(
            id: 2,
            name: "Ember Field",
            subtitle: "Solar winds pick up speed",
            palette: LevelPalette(
                background: [UIColor(red: 0.18, green: 0.05, blue: 0.04, alpha: 1), UIColor(red: 0.08, green: 0.02, blue: 0.02, alpha: 1)],
                planetInner: UIColor(red: 0.95, green: 0.55, blue: 0.25, alpha: 1),
                planetOuter: UIColor(red: 0.45, green: 0.15, blue: 0.05, alpha: 1),
                fire: UIColor(red: 1.00, green: 0.35, blue: 0.15, alpha: 1),
                ice: UIColor(red: 0.55, green: 0.85, blue: 1.00, alpha: 1),
                accent: UIColor(red: 1.00, green: 0.70, blue: 0.35, alpha: 1)
            ),
            difficulty: LevelDifficulty(
                startingLives: 3,
                baseRotationSpeed: 1.9,
                rotationAcceleration: 0.07,
                maxRotationSpeed: 6.8,
                baseAsteroidSpeed: 95,
                asteroidSpeedAcceleration: 2.2,
                baseSpawnInterval: 1.9,
                minSpawnInterval: 0.6,
                spawnTightening: 0.04
            )
        ),
        LevelConfiguration(
            id: 3,
            name: "Frostbite Belt",
            subtitle: "Ice storms cluster fast",
            palette: LevelPalette(
                background: [UIColor(red: 0.02, green: 0.13, blue: 0.16, alpha: 1), UIColor(red: 0.01, green: 0.05, blue: 0.07, alpha: 1)],
                planetInner: UIColor(red: 0.30, green: 0.80, blue: 0.80, alpha: 1),
                planetOuter: UIColor(red: 0.05, green: 0.30, blue: 0.35, alpha: 1),
                fire: UIColor(red: 1.00, green: 0.50, blue: 0.25, alpha: 1),
                ice: UIColor(red: 0.55, green: 0.95, blue: 0.95, alpha: 1),
                accent: UIColor(red: 0.60, green: 0.95, blue: 0.90, alpha: 1)
            ),
            difficulty: LevelDifficulty(
                startingLives: 3,
                baseRotationSpeed: 2.2,
                rotationAcceleration: 0.09,
                maxRotationSpeed: 7.5,
                baseAsteroidSpeed: 110,
                asteroidSpeedAcceleration: 2.6,
                baseSpawnInterval: 1.7,
                minSpawnInterval: 0.52,
                spawnTightening: 0.05
            )
        ),
        LevelConfiguration(
            id: 4,
            name: "Nebula Siege",
            subtitle: "Chaos rises across the orbit",
            palette: LevelPalette(
                background: [UIColor(red: 0.12, green: 0.04, blue: 0.20, alpha: 1), UIColor(red: 0.05, green: 0.02, blue: 0.10, alpha: 1)],
                planetInner: UIColor(red: 0.65, green: 0.40, blue: 0.95, alpha: 1),
                planetOuter: UIColor(red: 0.25, green: 0.10, blue: 0.45, alpha: 1),
                fire: UIColor(red: 1.00, green: 0.40, blue: 0.55, alpha: 1),
                ice: UIColor(red: 0.55, green: 0.75, blue: 1.00, alpha: 1),
                accent: UIColor(red: 0.85, green: 0.60, blue: 1.00, alpha: 1)
            ),
            difficulty: LevelDifficulty(
                startingLives: 2,
                baseRotationSpeed: 2.5,
                rotationAcceleration: 0.11,
                maxRotationSpeed: 8.2,
                baseAsteroidSpeed: 125,
                asteroidSpeedAcceleration: 3.0,
                baseSpawnInterval: 1.5,
                minSpawnInterval: 0.46,
                spawnTightening: 0.06
            )
        ),
        LevelConfiguration(
            id: 5,
            name: "Solar Eclipse",
            subtitle: "The final unforgiving vigil",
            palette: LevelPalette(
                background: [UIColor(red: 0.10, green: 0.09, blue: 0.02, alpha: 1), UIColor(red: 0.03, green: 0.02, blue: 0.00, alpha: 1)],
                planetInner: UIColor(red: 0.95, green: 0.80, blue: 0.30, alpha: 1),
                planetOuter: UIColor(red: 0.40, green: 0.30, blue: 0.05, alpha: 1),
                fire: UIColor(red: 1.00, green: 0.55, blue: 0.10, alpha: 1),
                ice: UIColor(red: 0.65, green: 0.90, blue: 1.00, alpha: 1),
                accent: UIColor(red: 1.00, green: 0.85, blue: 0.40, alpha: 1)
            ),
            difficulty: LevelDifficulty(
                startingLives: 2,
                baseRotationSpeed: 2.9,
                rotationAcceleration: 0.14,
                maxRotationSpeed: 9.0,
                baseAsteroidSpeed: 145,
                asteroidSpeedAcceleration: 3.6,
                baseSpawnInterval: 1.3,
                minSpawnInterval: 0.4,
                spawnTightening: 0.08
            )
        )
    ]

    static func level(with id: Int) -> LevelConfiguration {
        levels.first(where: { $0.id == id }) ?? levels[0]
    }
}
