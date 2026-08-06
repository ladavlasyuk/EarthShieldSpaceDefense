import Foundation

final class StatisticsStore {

    static let shared = StatisticsStore()

    private let defaults = UserDefaults.standard
    private let storageKey = "level_statistics_collection"

    private var cache: [Int: LevelStatistics]

    private init() {
        if
            let data = defaults.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Int: LevelStatistics].self, from: data)
        {
            cache = decoded
        } else {
            cache = [:]
        }
    }

    func statistics(for levelID: Int) -> LevelStatistics {
        cache[levelID] ?? LevelStatistics(levelID: levelID)
    }

    func allStatistics() -> [LevelStatistics] {
        LevelCatalog.levels.map { statistics(for: $0.id) }
    }

    func record(_ result: GameResult) {
        var stats = statistics(for: result.levelID)
        stats.gamesPlayed += 1
        stats.highScore = max(stats.highScore, result.score)
        stats.bestSurvivalTime = max(stats.bestSurvivalTime, result.survivalTime)
        stats.totalBlocked += result.blocked
        stats.totalMissed += result.missed
        stats.totalExplosions += result.explosions
        stats.bestCombo = max(stats.bestCombo, result.bestCombo)
        stats.powerUpsCollected += result.powerUpsCollected
        stats.pulsesUsed += result.pulsesUsed
        stats.lastScore = result.score
        stats.lastSurvivalTime = result.survivalTime
        stats.lastPlayed = Date()
        cache[result.levelID] = stats
        persist()
    }

    func resetAll() {
        cache = [:]
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(cache) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
