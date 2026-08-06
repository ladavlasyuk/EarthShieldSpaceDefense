import SpriteKit

final class AsteroidNode: SKShapeNode {
    var kind: ElementKind = .fire
    var direction: CGVector = .zero
    var passedShields = false
    var resolved = false
}
