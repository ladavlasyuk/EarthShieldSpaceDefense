import UIKit

final class PlanetEmblemView: UIView {

    private let atmosphereLayer = CAGradientLayer()
    private let planetGradient = CAGradientLayer()
    private let planetMask = CAShapeLayer()
    private let orbitLayer = CAShapeLayer()
    private let fireLayer = CAShapeLayer()
    private let iceLayer = CAShapeLayer()
    private let rotatingContainer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = .clear

        atmosphereLayer.type = .radial
        atmosphereLayer.colors = [
            UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.5).cgColor,
            UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 0.12).cgColor,
            UIColor.clear.cgColor
        ]
        atmosphereLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        atmosphereLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.addSublayer(atmosphereLayer)

        layer.addSublayer(orbitLayer)

        planetGradient.type = .radial
        planetGradient.colors = [
            UIColor(red: 0.55, green: 0.78, blue: 1.0, alpha: 1).cgColor,
            UIColor(red: 0.20, green: 0.50, blue: 0.92, alpha: 1).cgColor,
            UIColor(red: 0.05, green: 0.18, blue: 0.45, alpha: 1).cgColor
        ]
        planetGradient.locations = [0.0, 0.55, 1.0]
        planetGradient.startPoint = CGPoint(x: 0.35, y: 0.32)
        planetGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        planetGradient.mask = planetMask
        layer.addSublayer(planetGradient)

        layer.addSublayer(rotatingContainer)
        configureMoon(fireLayer, color: UIColor(red: 1.0, green: 0.45, blue: 0.2, alpha: 1))
        configureMoon(iceLayer, color: UIColor(red: 0.45, green: 0.8, blue: 1.0, alpha: 1))
        rotatingContainer.addSublayer(fireLayer)
        rotatingContainer.addSublayer(iceLayer)
    }

    private func configureMoon(_ moon: CAShapeLayer, color: UIColor) {
        moon.fillColor = color.cgColor
        moon.shadowColor = color.cgColor
        moon.shadowRadius = 8
        moon.shadowOpacity = 0.9
        moon.shadowOffset = .zero
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let planetRadius = bounds.height * 0.22
        let orbitRadius = bounds.height * 0.42

        atmosphereLayer.frame = CGRect(
            x: center.x - planetRadius * 2.2,
            y: center.y - planetRadius * 2.2,
            width: planetRadius * 4.4,
            height: planetRadius * 4.4
        )

        planetGradient.frame = CGRect(
            x: center.x - planetRadius,
            y: center.y - planetRadius,
            width: planetRadius * 2,
            height: planetRadius * 2
        )
        planetMask.path = UIBezierPath(ovalIn: planetGradient.bounds).cgPath

        orbitLayer.path = UIBezierPath(arcCenter: center, radius: orbitRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        orbitLayer.fillColor = UIColor.clear.cgColor
        orbitLayer.strokeColor = UIColor.white.withAlphaComponent(0.18).cgColor
        orbitLayer.lineWidth = 1

        rotatingContainer.frame = bounds

        let dotRadius = bounds.height * 0.08
        fireLayer.path = UIBezierPath(arcCenter: CGPoint(x: center.x + orbitRadius, y: center.y), radius: dotRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        iceLayer.path = UIBezierPath(arcCenter: CGPoint(x: center.x - orbitRadius, y: center.y), radius: dotRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath

        startRotation()
    }

    private func startRotation() {
        guard rotatingContainer.animation(forKey: "spin") == nil else { return }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 6
        animation.repeatCount = .infinity
        rotatingContainer.add(animation, forKey: "spin")
    }
}
