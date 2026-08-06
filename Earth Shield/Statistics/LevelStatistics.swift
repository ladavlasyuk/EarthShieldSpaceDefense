import Foundation

struct LevelStatistics: Codable {
    var levelID: Int
    var gamesPlayed: Int = 0
    var highScore: Int = 0
    var bestSurvivalTime: TimeInterval = 0
    var totalBlocked: Int = 0
    var totalMissed: Int = 0
    var totalExplosions: Int = 0
    var bestCombo: Int = 0
    var powerUpsCollected: Int = 0
    var pulsesUsed: Int = 0
    var lastScore: Int = 0
    var lastSurvivalTime: TimeInterval = 0
    var lastPlayed: Date?

    var totalAsteroids: Int { totalBlocked + totalMissed + totalExplosions }

    var accuracy: Double {
        let attempts = totalBlocked + totalExplosions
        guard attempts > 0 else { return 0 }
        return Double(totalBlocked) / Double(attempts)
    }

    var averageScore: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(highScore + lastScore) / Double(max(gamesPlayed, 1))
    }
}

struct GameResult {
    let levelID: Int
    let score: Int
    let survivalTime: TimeInterval
    let blocked: Int
    let missed: Int
    let explosions: Int
    let bestCombo: Int
    let powerUpsCollected: Int
    let pulsesUsed: Int
}
