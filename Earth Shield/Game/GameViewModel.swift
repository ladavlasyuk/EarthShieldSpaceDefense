import UIKit

final class GameViewModel {

    let level: LevelConfiguration

    private(set) var score = 0
    private(set) var lives: Int
    private(set) var elapsed: TimeInterval = 0
    private(set) var blocked = 0
    private(set) var missed = 0
    private(set) var explosions = 0
    private(set) var combo = 0
    private(set) var bestCombo = 0
    private(set) var powerUpsCollected = 0
    private(set) var pulsesUsed = 0
    private(set) var pulseCharge: CGFloat = 0
    private(set) var isOver = false

    let maxLives = 6
    private let pulseGainPerBlock: CGFloat = 0.09

    var onScoreChanged: ((Int) -> Void)?
    var onLivesChanged: ((Int) -> Void)?
    var onTimeChanged: ((TimeInterval) -> Void)?
    var onComboChanged: ((Int, Int) -> Void)?
    var onPulseChargeChanged: ((CGFloat) -> Void)?
    var onPowerUpCollected: ((PowerUpKind) -> Void)?
    var onGameOver: ((GameResult) -> Void)?

    private let store = StatisticsStore.shared

    init(level: LevelConfiguration) {
        self.level = level
        self.lives = level.difficulty.startingLives
    }

    func advance(by delta: TimeInterval) {
        guard !isOver else { return }
        elapsed += delta
        onTimeChanged?(elapsed)
    }

    var comboMultiplier: Int {
        min(1 + combo / 4, 6)
    }

    var isPulseReady: Bool { pulseCharge >= 1.0 }

    var currentRotationSpeed: CGFloat {
        let difficulty = level.difficulty
        let value = difficulty.baseRotationSpeed + CGFloat(elapsed) * difficulty.rotationAcceleration
        return min(value, difficulty.maxRotationSpeed)
    }

    var currentAsteroidSpeed: CGFloat {
        let difficulty = level.difficulty
        return difficulty.baseAsteroidSpeed + CGFloat(elapsed) * difficulty.asteroidSpeedAcceleration
    }

    var currentSpawnInterval: TimeInterval {
        let difficulty = level.difficulty
        let value = difficulty.baseSpawnInterval - elapsed * difficulty.spawnTightening
        return max(value, difficulty.minSpawnInterval)
    }

    func registerBlock() {
        guard !isOver else { return }
        blocked += 1
        combo += 1
        bestCombo = max(bestCombo, combo)
        let base = 10 + Int(elapsed / 5.0)
        score += base * comboMultiplier
        onScoreChanged?(score)
        onComboChanged?(combo, comboMultiplier)
        increasePulse(by: pulseGainPerBlock)
    }

    func registerMiss() {
        guard !isOver else { return }
        missed += 1
        resetCombo()
        loseLife()
    }

    func registerExplosion() {
        guard !isOver else { return }
        explosions += 1
        resetCombo()
        finish()
    }

    func collectPowerUp(_ kind: PowerUpKind) {
        guard !isOver else { return }
        powerUpsCollected += 1
        switch kind {
        case .extraShield:
            gainLife()
        case .scoreBurst:
            score += 60 + combo * 6
            onScoreChanged?(score)
        case .slowMotion, .freezeRotation:
            break
        }
        increasePulse(by: 0.12)
        onPowerUpCollected?(kind)
    }

    func usePulse(clearedCount: Int) {
        guard !isOver, isPulseReady else { return }
        pulsesUsed += 1
        pulseCharge = 0
        onPulseChargeChanged?(pulseCharge)
        score += clearedCount * 15
        onScoreChanged?(score)
    }

    private func increasePulse(by amount: CGFloat) {
        pulseCharge = min(pulseCharge + amount, 1.0)
        onPulseChargeChanged?(pulseCharge)
    }

    private func resetCombo() {
        guard combo != 0 else { return }
        combo = 0
        onComboChanged?(combo, comboMultiplier)
    }

    private func gainLife() {
        lives = min(lives + 1, maxLives)
        onLivesChanged?(lives)
    }

    private func loseLife() {
        lives = max(lives - 1, 0)
        onLivesChanged?(lives)
        if lives <= 0 {
            finish()
        }
    }

    private func finish() {
        guard !isOver else { return }
        isOver = true
        let result = GameResult(
            levelID: level.id,
            score: score,
            survivalTime: elapsed,
            blocked: blocked,
            missed: missed,
            explosions: explosions,
            bestCombo: bestCombo,
            powerUpsCollected: powerUpsCollected,
            pulsesUsed: pulsesUsed
        )
        store.record(result)
        onGameOver?(result)
    }
}
