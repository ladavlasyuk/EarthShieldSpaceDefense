import UIKit

struct Achievement {
    let title: String
    let detail: String
    let symbolName: String
    let current: Int
    let target: Int

    var isUnlocked: Bool { current >= target }
    var progress: Double { min(Double(current) / Double(target), 1.0) }
}

enum AchievementsProvider {

    static func evaluate() -> [Achievement] {
        let all = StatisticsStore.shared.allStatistics()

        let totalGames = all.reduce(0) { $0 + $1.gamesPlayed }
        let totalBlocked = all.reduce(0) { $0 + $1.totalBlocked }
        let totalPowerUps = all.reduce(0) { $0 + $1.powerUpsCollected }
        let totalPulses = all.reduce(0) { $0 + $1.pulsesUsed }
        let bestCombo = all.map(\.bestCombo).max() ?? 0
        let bestSurvival = Int((all.map(\.bestSurvivalTime).max() ?? 0).rounded())
        let bestScore = all.map(\.highScore).max() ?? 0

        return [
            Achievement(title: "First Contact", detail: "Play your first round", symbolName: "flag.fill", current: totalGames, target: 1),
            Achievement(title: "Guardian", detail: "Block 100 asteroids", symbolName: "shield.lefthalf.filled", current: totalBlocked, target: 100),
            Achievement(title: "Veteran Pilot", detail: "Play 25 rounds", symbolName: "airplane", current: totalGames, target: 25),
            Achievement(title: "Combo Master", detail: "Reach a 20-hit combo", symbolName: "bolt.fill", current: bestCombo, target: 20),
            Achievement(title: "Collector", detail: "Gather 25 power-ups", symbolName: "sparkles", current: totalPowerUps, target: 25),
            Achievement(title: "Pulse Engineer", detail: "Trigger 10 pulses", symbolName: "wave.3.right", current: totalPulses, target: 10),
            Achievement(title: "Survivor", detail: "Last 120 seconds in a round", symbolName: "timer", current: bestSurvival, target: 120),
            Achievement(title: "High Scorer", detail: "Score 1000 in a single round", symbolName: "crown.fill", current: bestScore, target: 1000)
        ]
    }
}
