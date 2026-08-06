import UIKit

final class MenuViewController: UIViewController {

    private let background = GradientView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationCoordinator.lockToPortrait(for: self)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override var prefersStatusBarHidden: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    private func configureBackground() {
        background.translatesAutoresizingMaskIntoConstraints = false
        background.apply(colors: [
            UIColor(red: 0.07, green: 0.10, blue: 0.24, alpha: 1),
            UIColor(red: 0.02, green: 0.02, blue: 0.05, alpha: 1)
        ])
        view.addSubview(background)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        addGlow(color: UIColor(red: 0.30, green: 0.55, blue: 1.0, alpha: 1), center: CGPoint(x: 0.2, y: 0.22), radius: 1.1)
        addGlow(color: UIColor(red: 1.0, green: 0.45, blue: 0.30, alpha: 1), center: CGPoint(x: 0.85, y: 0.75), radius: 0.9)
        addGlow(color: UIColor(red: 0.45, green: 0.85, blue: 1.0, alpha: 1), center: CGPoint(x: 0.8, y: 0.15), radius: 0.7)
        addStarfield()
    }

    private func addGlow(color: UIColor, center: CGPoint, radius: CGFloat) {
        let glow = RadialGlowView(color: color)
        glow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(glow)
        let dimension = UIScreen.main.bounds.width * radius
        NSLayoutConstraint.activate([
            glow.widthAnchor.constraint(equalToConstant: dimension * 1.6),
            glow.heightAnchor.constraint(equalToConstant: dimension * 1.6),
            glow.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: UIScreen.main.bounds.width * center.x),
            glow.centerYAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height * center.y)
        ])
    }

    private func addStarfield() {
        let starLayer = CALayer()
        starLayer.frame = UIScreen.main.bounds
        for _ in 0..<60 {
            let dot = CALayer()
            let size = CGFloat.random(in: 1...2.6)
            dot.frame = CGRect(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height),
                width: size, height: size
            )
            dot.backgroundColor = UIColor.white.cgColor
            dot.cornerRadius = size / 2
            dot.opacity = Float.random(in: 0.2...0.8)
            starLayer.addSublayer(dot)
        }
        view.layer.addSublayer(starLayer)
    }

    private func configureContent() {
        let planet = PlanetEmblemView()
        planet.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "EARTH SHIELD"
        titleLabel.font = .systemFont(ofSize: 40, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1).cgColor
        titleLabel.layer.shadowRadius = 16
        titleLabel.layer.shadowOpacity = 0.9
        titleLabel.layer.shadowOffset = .zero

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Swing the fire and ice shields.\nBlock the opposite element. Never match."
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor(white: 0.75, alpha: 1)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let playButton = makeButton(title: "Play", filled: true)
        playButton.onTap = { [weak self] in self?.openLevels() }

        let howToButton = makeButton(title: "How to Play", filled: false)
        howToButton.onTap = { [weak self] in self?.openHowToPlay() }

        let achievementsButton = makeButton(title: "Achievements", filled: false)
        achievementsButton.onTap = { [weak self] in self?.openAchievements() }

        let statsButton = makeButton(title: "Statistics", filled: false)
        statsButton.onTap = { [weak self] in self?.openStatistics() }

        let stack = UIStackView(arrangedSubviews: [planet, titleLabel, subtitleLabel, playButton, howToButton, achievementsButton, statsButton])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.setCustomSpacing(26, after: subtitleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            planet.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func makeButton(title: String, filled: Bool) -> StyledButton {
        let button = StyledButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        if filled {
            button.apply(
                colors: [
                    UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 1),
                    UIColor(red: 0.20, green: 0.45, blue: 0.95, alpha: 1)
                ],
                cornerRadius: 18,
                glowColor: UIColor(red: 0.30, green: 0.55, blue: 1.0, alpha: 1)
            )
            button.setTitleColor(.white, for: .normal)
        } else {
            button.apply(
                colors: [
                    UIColor(white: 0.22, alpha: 0.9),
                    UIColor(white: 0.10, alpha: 0.9)
                ],
                cornerRadius: 18
            )
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
            button.setTitleColor(.white, for: .normal)
        }
        return button
    }

    private func openLevels() {
        navigationController?.pushViewController(LevelSelectViewController(), animated: true)
    }

    private func openStatistics() {
        navigationController?.pushViewController(StatisticsViewController(), animated: true)
    }

    private func openHowToPlay() {
        navigationController?.pushViewController(HowToPlayViewController(), animated: true)
    }

    private func openAchievements() {
        navigationController?.pushViewController(AchievementsViewController(), animated: true)
    }
}
