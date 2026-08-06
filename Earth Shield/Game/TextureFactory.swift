import UIKit
import SpriteKit

enum TextureFactory {

    static func sphere(diameter: CGFloat, highlight: UIColor, base: UIColor, shadow: UIColor) -> SKTexture {
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let ctx = context.cgContext
            let colors = [highlight.cgColor, base.cgColor, shadow.cgColor] as CFArray
            let locations: [CGFloat] = [0.0, 0.55, 1.0]
            let space = CGColorSpaceCreateDeviceRGB()
            guard let gradient = CGGradient(colorsSpace: space, colors: colors, locations: locations) else { return }

            let radius = diameter / 2
            ctx.addEllipse(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
            ctx.clip()

            let lightCenter = CGPoint(x: radius * 0.66, y: radius * 0.62)
            let outerCenter = CGPoint(x: radius, y: radius)
            ctx.drawRadialGradient(
                gradient,
                startCenter: lightCenter,
                startRadius: 0,
                endCenter: outerCenter,
                endRadius: radius,
                options: []
            )
        }
        return SKTexture(image: image)
    }

    static func glow(diameter: CGFloat, color: UIColor) -> SKTexture {
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let ctx = context.cgContext
            let colors = [
                color.withAlphaComponent(0.9).cgColor,
                color.withAlphaComponent(0.35).cgColor,
                color.withAlphaComponent(0.0).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0.0, 0.45, 1.0]
            let space = CGColorSpaceCreateDeviceRGB()
            guard let gradient = CGGradient(colorsSpace: space, colors: colors, locations: locations) else { return }
            let radius = diameter / 2
            let center = CGPoint(x: radius, y: radius)
            ctx.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
        }
        return SKTexture(image: image)
    }

    static func verticalGradient(size: CGSize, colors: [UIColor]) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgColors = colors.map { $0.cgColor } as CFArray
            let space = CGColorSpaceCreateDeviceRGB()
            let locations: [CGFloat] = [0, 1]
            if let gradient = CGGradient(colorsSpace: space, colors: cgColors, locations: locations) {
                context.cgContext.drawLinearGradient(
                    gradient,
                    start: .zero,
                    end: CGPoint(x: 0, y: size.height),
                    options: []
                )
            }
        }
        return SKTexture(image: image)
    }

    static func softBlob(diameter: CGFloat, color: UIColor) -> SKTexture {
        glow(diameter: diameter, color: color)
    }
}

extension UIColor {

    func lighter(by amount: CGFloat) -> UIColor {
        adjust(by: amount)
    }

    func darker(by amount: CGFloat) -> UIColor {
        adjust(by: -amount)
    }

    private func adjust(by amount: CGFloat) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return self }
        return UIColor(
            red: min(max(red + amount, 0), 1),
            green: min(max(green + amount, 0), 1),
            blue: min(max(blue + amount, 0), 1),
            alpha: alpha
        )
    }
}
