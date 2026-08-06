import SpriteKit

final class GameScene: SKScene {

    var viewModel: GameViewModel!

    var rotationInput: CGFloat = 0

    private let driftDirection: CGFloat = 1

    private let shieldContainer = SKNode()
    private var fireShield: SKNode!
    private var iceShield: SKNode!
    private var planet: SKSpriteNode!
    private var planetAtmosphere: SKSpriteNode!

    private var asteroids: [AsteroidNode] = []
    private var powerUps: [PowerUpNode] = []

    private var lastUpdateTime: TimeInterval = 0
    private var spawnAccumulator: TimeInterval = 0
    private var powerUpAccumulator: TimeInterval = 0
    private var nextPowerUpInterval: TimeInterval = 7
    private var slowMotionRemaining: TimeInterval = 0
    private var freezeRemaining: TimeInterval = 0

    private var speedFactor: CGFloat { slowMotionRemaining > 0 ? 0.45 : 1.0 }
    private var rotationFactor: CGFloat { freezeRemaining > 0 ? 0.28 : 1.0 }

    private var sceneCenter: CGPoint = .zero
    private var planetRadius: CGFloat = 0
    private var orbitRadius: CGFloat = 0
    private var shieldThickness: CGFloat = 0
    private var asteroidRadius: CGFloat = 0
    private let arcHalfWidth: CGFloat = 0.40

    private var fireGlowTexture: SKTexture!
    private var iceGlowTexture: SKTexture!
    private var fireSphereTexture: SKTexture!
    private var iceSphereTexture: SKTexture!

    private var palette: LevelPalette { viewModel.level.palette }

    override func didMove(to view: SKView) {
        backgroundColor = palette.background.last ?? .black
        let unit = min(size.width, size.height)
        sceneCenter = CGPoint(x: size.width / 2, y: size.height * 0.47)
        planetRadius = unit * 0.082
        orbitRadius = planetRadius + unit * 0.17
        shieldThickness = unit * 0.055
        asteroidRadius = unit * 0.033

        prepareTextures()
        buildBackground()
        buildStars()
        buildPlanet()
        buildShields()
    }

    private func prepareTextures() {
        let asteroidDiameter = asteroidRadius * 2
        fireSphereTexture = TextureFactory.sphere(
            diameter: asteroidDiameter,
            highlight: palette.fire.lighter(by: 0.35),
            base: palette.fire,
            shadow: palette.fire.darker(by: 0.4)
        )
        iceSphereTexture = TextureFactory.sphere(
            diameter: asteroidDiameter,
            highlight: palette.ice.lighter(by: 0.35),
            base: palette.ice,
            shadow: palette.ice.darker(by: 0.4)
        )
        fireGlowTexture = TextureFactory.glow(diameter: asteroidDiameter * 2.4, color: palette.fire)
        iceGlowTexture = TextureFactory.glow(diameter: asteroidDiameter * 2.4, color: palette.ice)
    }

    private func buildBackground() {
        let gradient = SKSpriteNode(texture: TextureFactory.verticalGradient(size: size, colors: palette.background))
        gradient.position = sceneCenter
        gradient.zPosition = -100
        gradient.size = size
        addChild(gradient)

        addNebula(color: palette.accent, scale: 1.0, offset: CGPoint(x: -size.width * 0.28, y: size.height * 0.22))
        addNebula(color: palette.fire, scale: 0.8, offset: CGPoint(x: size.width * 0.34, y: -size.height * 0.18))
        addNebula(color: palette.ice, scale: 0.7, offset: CGPoint(x: size.width * 0.18, y: size.height * 0.34))
    }

    private func addNebula(color: UIColor, scale: CGFloat, offset: CGPoint) {
        let diameter = max(size.width, size.height) * 0.9 * scale
        let blob = SKSpriteNode(texture: TextureFactory.softBlob(diameter: diameter, color: color.withAlphaComponent(0.5)))
        blob.size = CGSize(width: diameter, height: diameter)
        blob.position = CGPoint(x: sceneCenter.x + offset.x, y: sceneCenter.y + offset.y)
        blob.zPosition = -95
        blob.alpha = 0.35
        blob.blendMode = .add
        blob.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.18, duration: Double.random(in: 3.0...5.0)),
            SKAction.fadeAlpha(to: 0.4, duration: Double.random(in: 3.0...5.0))
        ])))
        addChild(blob)
    }

    private func buildStars() {
        for _ in 0..<110 {
            let depth = CGFloat.random(in: 0.3...1.0)
            let star = SKShapeNode(circleOfRadius: depth * 1.9)
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = depth * 0.8
            star.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height))
            star.zPosition = -90
            star.glowWidth = depth
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: depth * 0.15, duration: Double.random(in: 0.8...2.4)),
                SKAction.fadeAlpha(to: depth * 0.85, duration: Double.random(in: 0.8...2.4))
            ])
            star.run(SKAction.repeatForever(twinkle))
            addChild(star)
        }
    }

    private func buildPlanet() {
        let atmosphereDiameter = planetRadius * 3.4
        planetAtmosphere = SKSpriteNode(texture: TextureFactory.glow(diameter: atmosphereDiameter, color: palette.accent))
        planetAtmosphere.size = CGSize(width: atmosphereDiameter, height: atmosphereDiameter)
        planetAtmosphere.position = sceneCenter
        planetAtmosphere.zPosition = 3
        planetAtmosphere.blendMode = .add
        planetAtmosphere.alpha = 0.55
        planetAtmosphere.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.08, duration: 1.6),
            SKAction.scale(to: 1.0, duration: 1.6)
        ])))
        addChild(planetAtmosphere)

        let body = TextureFactory.sphere(
            diameter: planetRadius * 2,
            highlight: palette.planetInner.lighter(by: 0.3),
            base: palette.planetInner,
            shadow: palette.planetOuter.darker(by: 0.15)
        )
        planet = SKSpriteNode(texture: body)
        planet.size = CGSize(width: planetRadius * 2, height: planetRadius * 2)
        planet.position = sceneCenter
        planet.zPosition = 5
        addChild(planet)

        let glintDiameter = planetRadius * 0.9
        let glint = SKSpriteNode(texture: TextureFactory.glow(diameter: glintDiameter, color: .white))
        glint.size = CGSize(width: glintDiameter, height: glintDiameter)
        glint.blendMode = .add
        glint.alpha = 0.6
        glint.position = CGPoint(x: sceneCenter.x - planetRadius * 0.32, y: sceneCenter.y + planetRadius * 0.34)
        glint.zPosition = 6
        addChild(glint)

        let rim = SKShapeNode(circleOfRadius: planetRadius)
        rim.fillColor = .clear
        rim.strokeColor = palette.accent.withAlphaComponent(0.7)
        rim.lineWidth = 2
        rim.glowWidth = 3
        rim.position = sceneCenter
        rim.zPosition = 6
        addChild(rim)

        buildOrbitGuide()

        let halo = SKShapeNode(circleOfRadius: planetRadius * 1.3)
        halo.fillColor = .clear
        halo.strokeColor = palette.accent.withAlphaComponent(0.18)
        halo.lineWidth = 1.5
        halo.position = sceneCenter
        halo.zPosition = 4
        halo.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.06, duration: 1.4),
            SKAction.scale(to: 1.0, duration: 1.4)
        ])))
        addChild(halo)
    }

    private func buildOrbitGuide() {
        let guide = SKShapeNode(circleOfRadius: orbitRadius)
        guide.fillColor = .clear
        guide.strokeColor = UIColor.white.withAlphaComponent(0.10)
        guide.lineWidth = 1
        guide.position = sceneCenter
        guide.zPosition = 2
        addChild(guide)
    }

    private func buildShields() {
        shieldContainer.position = sceneCenter
        shieldContainer.zPosition = 10
        addChild(shieldContainer)

        fireShield = makeShield(centerAngle: 0, color: palette.fire)
        iceShield = makeShield(centerAngle: .pi, color: palette.ice)
        shieldContainer.addChild(fireShield)
        shieldContainer.addChild(iceShield)
    }

    private func makeShield(centerAngle: CGFloat, color: UIColor) -> SKNode {
        let container = SKNode()

        let path = CGMutablePath()
        path.addArc(
            center: .zero,
            radius: orbitRadius,
            startAngle: centerAngle - arcHalfWidth,
            endAngle: centerAngle + arcHalfWidth,
            clockwise: false
        )

        let aura = SKShapeNode(path: path)
        aura.strokeColor = color.withAlphaComponent(0.4)
        aura.lineWidth = shieldThickness * 1.5
        aura.glowWidth = shieldThickness * 0.6
        aura.blendMode = .add
        container.addChild(aura)

        let core = SKShapeNode(path: path)
        core.strokeColor = color
        core.lineWidth = shieldThickness
        core.glowWidth = shieldThickness * 0.18
        container.addChild(core)

        let highlightPath = CGMutablePath()
        highlightPath.addArc(
            center: .zero,
            radius: orbitRadius + shieldThickness * 0.28,
            startAngle: centerAngle - arcHalfWidth * 0.82,
            endAngle: centerAngle + arcHalfWidth * 0.82,
            clockwise: false
        )
        let highlight = SKShapeNode(path: highlightPath)
        highlight.strokeColor = color.lighter(by: 0.4).withAlphaComponent(0.9)
        highlight.lineWidth = shieldThickness * 0.18
        highlight.blendMode = .add
        container.addChild(highlight)

        return container
    }

    override func update(_ currentTime: TimeInterval) {
        guard viewModel != nil, !viewModel.isOver else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        var delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        delta = min(delta, 0.05)

        decayEffects(delta)
        viewModel.advance(by: delta)
        rotateShields(delta)
        handleSpawning(delta)
        handlePowerUpSpawning(delta)
        moveAsteroids(delta)
        movePowerUps(delta)
    }

    private func decayEffects(_ delta: TimeInterval) {
        if slowMotionRemaining > 0 { slowMotionRemaining -= delta }
        if freezeRemaining > 0 { freezeRemaining -= delta }
    }

    private func rotateShields(_ delta: TimeInterval) {
        let speed = viewModel.currentRotationSpeed * rotationFactor
        if rotationInput != 0 {
            shieldContainer.zRotation += rotationInput * speed * CGFloat(delta)
        } else {
            shieldContainer.zRotation += driftDirection * speed * 0.35 * CGFloat(delta)
        }
    }

    private func handleSpawning(_ delta: TimeInterval) {
        guard asteroids.isEmpty else {
            spawnAccumulator = 0
            return
        }
        spawnAccumulator += delta
        guard spawnAccumulator >= viewModel.currentSpawnInterval else { return }
        spawnAccumulator = 0
        spawnAsteroid()
    }

    private func spawnAsteroid() {
        let kind = ElementKind.allCases.randomElement() ?? .fire
        let radius = asteroidRadius
        let asteroid = AsteroidNode(circleOfRadius: radius)
        asteroid.kind = kind
        asteroid.fillColor = .white
        asteroid.strokeColor = .clear
        asteroid.fillTexture = kind == .fire ? fireSphereTexture : iceSphereTexture
        asteroid.zPosition = 8

        let glow = SKSpriteNode(texture: kind == .fire ? fireGlowTexture : iceGlowTexture)
        let glowSize = radius * 4.2
        glow.size = CGSize(width: glowSize, height: glowSize)
        glow.blendMode = .add
        glow.alpha = 0.8
        glow.zPosition = -1
        asteroid.addChild(glow)

        let angle = CGFloat.random(in: 0...(2 * .pi))
        let spawnDistance = spawnRadius(for: angle)
        let spawnPoint = CGPoint(
            x: sceneCenter.x + cos(angle) * spawnDistance,
            y: sceneCenter.y + sin(angle) * spawnDistance
        )
        asteroid.position = spawnPoint

        let dx = sceneCenter.x - spawnPoint.x
        let dy = sceneCenter.y - spawnPoint.y
        let length = max(sqrt(dx * dx + dy * dy), 0.0001)
        asteroid.direction = CGVector(dx: dx / length, dy: dy / length)

        asteroid.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: Double.random(in: 3...6))))
        glow.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.5),
            SKAction.scale(to: 0.9, duration: 0.5)
        ])))

        addChild(asteroid)
        asteroids.append(asteroid)
    }

    private func moveAsteroids(_ delta: TimeInterval) {
        let speed = viewModel.currentAsteroidSpeed * speedFactor
        var survivors: [AsteroidNode] = []

        for asteroid in asteroids {
            if asteroid.resolved { continue }
            asteroid.position.x += asteroid.direction.dx * speed * CGFloat(delta)
            asteroid.position.y += asteroid.direction.dy * speed * CGFloat(delta)

            let distance = hypot(asteroid.position.x - sceneCenter.x, asteroid.position.y - sceneCenter.y)

            if !asteroid.passedShields && distance <= orbitRadius {
                resolveShieldContact(asteroid)
                if asteroid.resolved { continue }
            }

            if asteroid.passedShields && distance <= planetRadius * 0.95 {
                resolvePlanetImpact(asteroid)
                continue
            }

            survivors.append(asteroid)
        }

        asteroids = survivors
    }

    private func handlePowerUpSpawning(_ delta: TimeInterval) {
        powerUpAccumulator += delta
        guard powerUpAccumulator >= nextPowerUpInterval else { return }
        powerUpAccumulator = 0
        nextPowerUpInterval = TimeInterval.random(in: 6.5...10.0)
        spawnPowerUp()
    }

    private func spawnPowerUp() {
        let kind = PowerUpKind.allCases.randomElement() ?? .scoreBurst
        let radius = asteroidRadius * 1.08
        let node = PowerUpNode(circleOfRadius: radius)
        node.kind = kind
        node.fillColor = kind.color.withAlphaComponent(0.25)
        node.strokeColor = kind.color
        node.lineWidth = 3
        node.glowWidth = radius * 0.4
        node.zPosition = 9

        let glow = SKSpriteNode(texture: TextureFactory.glow(diameter: radius * 4.4, color: kind.color))
        glow.size = CGSize(width: radius * 4.4, height: radius * 4.4)
        glow.blendMode = .add
        glow.alpha = 0.7
        glow.zPosition = -1
        node.addChild(glow)

        if let icon = UIImage(systemName: kind.symbolName)?.withTintColor(.white, renderingMode: .alwaysOriginal) {
            let iconNode = SKSpriteNode(texture: SKTexture(image: icon))
            let iconSize = radius * 1.1
            iconNode.size = CGSize(width: iconSize, height: iconSize)
            iconNode.zPosition = 1
            node.addChild(iconNode)
        }

        let angle = CGFloat.random(in: 0...(2 * .pi))
        let spawnDistance = spawnRadius(for: angle)
        let spawnPoint = CGPoint(
            x: sceneCenter.x + cos(angle) * spawnDistance,
            y: sceneCenter.y + sin(angle) * spawnDistance
        )
        node.position = spawnPoint

        let dx = sceneCenter.x - spawnPoint.x
        let dy = sceneCenter.y - spawnPoint.y
        let length = max(sqrt(dx * dx + dy * dy), 0.0001)
        node.direction = CGVector(dx: dx / length, dy: dy / length)

        node.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.12, duration: 0.6),
            SKAction.scale(to: 0.94, duration: 0.6)
        ])))

        addChild(node)
        powerUps.append(node)
    }

    private func movePowerUps(_ delta: TimeInterval) {
        let speed = viewModel.currentAsteroidSpeed * 0.62 * speedFactor
        var survivors: [PowerUpNode] = []

        for node in powerUps {
            if node.resolved { continue }
            node.position.x += node.direction.dx * speed * CGFloat(delta)
            node.position.y += node.direction.dy * speed * CGFloat(delta)

            let distance = hypot(node.position.x - sceneCenter.x, node.position.y - sceneCenter.y)

            if distance <= orbitRadius {
                let nodeAngle = atan2(node.position.y - sceneCenter.y, node.position.x - sceneCenter.x)
                let fireAngle = shieldContainer.zRotation
                let iceAngle = shieldContainer.zRotation + .pi
                if angularDistance(nodeAngle, fireAngle) <= arcHalfWidth || angularDistance(nodeAngle, iceAngle) <= arcHalfWidth {
                    collect(node)
                    continue
                }
            }

            if distance <= planetRadius * 0.9 {
                node.resolved = true
                node.removeFromParent()
                continue
            }

            survivors.append(node)
        }

        powerUps = survivors
    }

    private func collect(_ node: PowerUpNode) {
        node.resolved = true
        let kind = node.kind
        spawnBlock(at: node.position, color: kind.color)
        node.removeFromParent()

        switch kind {
        case .slowMotion:
            slowMotionRemaining = 5.0
        case .freezeRotation:
            freezeRemaining = 5.0
        case .extraShield, .scoreBurst:
            break
        }
        viewModel.collectPowerUp(kind)
    }

    func detonatePulse() -> Int {
        let cleared = asteroids.filter { !$0.resolved }
        for asteroid in cleared {
            asteroid.resolved = true
            spawnExplosion(at: asteroid.position, color: asteroid.kind == .fire ? palette.fire : palette.ice)
            asteroid.removeFromParent()
        }
        asteroids.removeAll()
        playPulseWave()
        shakeCamera()
        return cleared.count
    }

    private func playPulseWave() {
        let wave = SKShapeNode(circleOfRadius: planetRadius)
        wave.position = sceneCenter
        wave.fillColor = .clear
        wave.strokeColor = palette.accent
        wave.lineWidth = 6
        wave.glowWidth = 8
        wave.zPosition = 20
        addChild(wave)
        let reach = max(size.width, size.height) / planetRadius
        wave.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: reach, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.6)
            ]),
            SKAction.removeFromParent()
        ]))

        let flash = SKSpriteNode(color: .white, size: size)
        flash.position = sceneCenter
        flash.zPosition = 19
        flash.alpha = 0
        flash.blendMode = .add
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.35, duration: 0.08),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))
    }

    private func resolveShieldContact(_ asteroid: AsteroidNode) {
        let asteroidAngle = atan2(asteroid.position.y - sceneCenter.y, asteroid.position.x - sceneCenter.x)
        let fireAngle = shieldContainer.zRotation
        let iceAngle = shieldContainer.zRotation + .pi

        if angularDistance(asteroidAngle, fireAngle) <= arcHalfWidth {
            settle(asteroid, against: .fire)
        } else if angularDistance(asteroidAngle, iceAngle) <= arcHalfWidth {
            settle(asteroid, against: .ice)
        } else {
            asteroid.passedShields = true
        }
    }

    private func settle(_ asteroid: AsteroidNode, against shield: ElementKind) {
        asteroid.resolved = true
        let contact = asteroid.position
        let tint = asteroid.kind == .fire ? palette.fire : palette.ice
        if asteroid.kind == shield {
            spawnExplosion(at: contact, color: tint)
            asteroid.removeFromParent()
            shakeCamera()
            viewModel.registerExplosion()
        } else {
            spawnBlock(at: contact, color: shield == .fire ? palette.fire : palette.ice)
            asteroid.removeFromParent()
            viewModel.registerBlock()
        }
    }

    private func resolvePlanetImpact(_ asteroid: AsteroidNode) {
        asteroid.resolved = true
        let tint = asteroid.kind == .fire ? palette.fire : palette.ice
        spawnExplosion(at: asteroid.position, color: tint)
        asteroid.removeFromParent()
        flashPlanet()
        viewModel.registerMiss()
    }

    private func spawnBlock(at point: CGPoint, color: UIColor) {
        let glow = SKSpriteNode(texture: TextureFactory.glow(diameter: planetRadius * 2.6, color: color))
        glow.position = point
        glow.size = CGSize(width: planetRadius * 1.4, height: planetRadius * 1.4)
        glow.blendMode = .add
        glow.zPosition = 12
        addChild(glow)
        glow.run(SKAction.sequence([
            SKAction.group([SKAction.scale(to: 2.4, duration: 0.4), SKAction.fadeOut(withDuration: 0.4)]),
            SKAction.removeFromParent()
        ]))

        let ring = SKShapeNode(circleOfRadius: planetRadius * 0.3)
        ring.position = point
        ring.strokeColor = color.lighter(by: 0.3)
        ring.fillColor = .clear
        ring.lineWidth = 4
        ring.glowWidth = 4
        ring.zPosition = 13
        addChild(ring)
        ring.run(SKAction.sequence([
            SKAction.group([SKAction.scale(to: 2.6, duration: 0.4), SKAction.fadeOut(withDuration: 0.4)]),
            SKAction.removeFromParent()
        ]))
    }

    private func spawnExplosion(at point: CGPoint, color: UIColor) {
        let glow = SKSpriteNode(texture: TextureFactory.glow(diameter: planetRadius * 3.2, color: color))
        glow.position = point
        glow.size = CGSize(width: planetRadius * 1.6, height: planetRadius * 1.6)
        glow.blendMode = .add
        glow.zPosition = 15
        addChild(glow)
        glow.run(SKAction.sequence([
            SKAction.group([SKAction.scale(to: 3.4, duration: 0.45), SKAction.fadeOut(withDuration: 0.45)]),
            SKAction.removeFromParent()
        ]))

        let flash = SKShapeNode(circleOfRadius: planetRadius * 0.5)
        flash.position = point
        flash.fillColor = .white
        flash.strokeColor = color
        flash.lineWidth = 3
        flash.zPosition = 16
        flash.glowWidth = planetRadius * 0.3
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.group([SKAction.scale(to: 2.6, duration: 0.35), SKAction.fadeOut(withDuration: 0.35)]),
            SKAction.removeFromParent()
        ]))

        for _ in 0..<12 {
            let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            spark.position = point
            spark.fillColor = color.lighter(by: 0.2)
            spark.strokeColor = .clear
            spark.glowWidth = 2
            spark.zPosition = 16
            addChild(spark)
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let reach = planetRadius * CGFloat.random(in: 0.8...1.6)
            let move = SKAction.move(by: CGVector(dx: cos(angle) * reach, dy: sin(angle) * reach), duration: 0.45)
            move.timingMode = .easeOut
            spark.run(SKAction.sequence([
                SKAction.group([move, SKAction.fadeOut(withDuration: 0.45), SKAction.scale(to: 0.2, duration: 0.45)]),
                SKAction.removeFromParent()
            ]))
        }
    }

    private func flashPlanet() {
        let overlay = SKSpriteNode(color: .white, size: planet.size)
        overlay.position = .zero
        overlay.alpha = 0.0
        overlay.zPosition = 1
        planet.addChild(overlay)
        overlay.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.06),
            SKAction.fadeOut(withDuration: 0.18),
            SKAction.removeFromParent()
        ]))
        planetAtmosphere.run(SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.6, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.25)
        ]))
    }

    private func shakeCamera() {
        let amplitude: CGFloat = 14
        let shake = SKAction.sequence([
            SKAction.moveBy(x: amplitude, y: 0, duration: 0.04),
            SKAction.moveBy(x: -amplitude * 2, y: 0, duration: 0.08),
            SKAction.moveBy(x: amplitude, y: 0, duration: 0.04)
        ])
        planet.run(shake)
        planetAtmosphere.run(shake)
    }

    private func spawnRadius(for angle: CGFloat) -> CGFloat {
        let dx = cos(angle)
        let dy = sin(angle)
        var distance = max(size.width, size.height)

        if abs(dx) > 0.0001 {
            let bound = dx > 0 ? size.width - sceneCenter.x : sceneCenter.x
            distance = min(distance, bound / abs(dx))
        }
        if abs(dy) > 0.0001 {
            let bound = dy > 0 ? size.height - sceneCenter.y : sceneCenter.y
            distance = min(distance, bound / abs(dy))
        }
        return distance + planetRadius * 2.2
    }

    private func angularDistance(_ lhs: CGFloat, _ rhs: CGFloat) -> CGFloat {
        abs(atan2(sin(lhs - rhs), cos(lhs - rhs)))
    }
}
