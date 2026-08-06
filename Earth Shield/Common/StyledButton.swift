import UIKit

final class StyledButton: ClosureButton {

    private let gradientLayer = CAGradientLayer()
    private let sheenLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayers()
    }

    private func configureLayers() {
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        sheenLayer.colors = [
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        sheenLayer.startPoint = CGPoint(x: 0.5, y: 0)
        sheenLayer.endPoint = CGPoint(x: 0.5, y: 0.6)
        layer.insertSublayer(sheenLayer, above: gradientLayer)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.45
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 8)
    }

    func apply(colors: [UIColor], cornerRadius: CGFloat, glowColor: UIColor? = nil) {
        gradientLayer.colors = colors.map { $0.cgColor }
        layer.cornerRadius = cornerRadius
        gradientLayer.cornerRadius = cornerRadius
        sheenLayer.cornerRadius = cornerRadius
        if let glowColor {
            layer.shadowColor = glowColor.cgColor
            layer.shadowOpacity = 0.6
            layer.shadowRadius = 16
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        sheenLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.55)
        if let imageView { bringSubviewToFront(imageView) }
        if let titleLabel { bringSubviewToFront(titleLabel) }
    }
}
