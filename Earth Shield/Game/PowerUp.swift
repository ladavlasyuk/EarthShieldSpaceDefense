import UIKit
import SpriteKit

enum PowerUpKind: CaseIterable {
    case extraShield
    case slowMotion
    case freezeRotation
    case scoreBurst

    var color: UIColor {
        switch self {
        case .extraShield: return UIColor(red: 0.40, green: 1.0, blue: 0.55, alpha: 1)
        case .slowMotion: return UIColor(red: 0.55, green: 0.75, blue: 1.0, alpha: 1)
        case .freezeRotation: return UIColor(red: 0.70, green: 0.95, blue: 1.0, alpha: 1)
        case .scoreBurst: return UIColor(red: 1.0, green: 0.85, blue: 0.30, alpha: 1)
        }
    }

    var symbolName: String {
        switch self {
        case .extraShield: return "heart.fill"
        case .slowMotion: return "tortoise.fill"
        case .freezeRotation: return "snowflake"
        case .scoreBurst: return "star.fill"
        }
    }

    var title: String {
        switch self {
        case .extraShield: return "+1 Shield"
        case .slowMotion: return "Slow Motion"
        case .freezeRotation: return "Stabilized"
        case .scoreBurst: return "Score Burst"
        }
    }
}

final class PowerUpNode: SKShapeNode {
    var kind: PowerUpKind = .scoreBurst
    var direction: CGVector = .zero
    var resolved = false
}
