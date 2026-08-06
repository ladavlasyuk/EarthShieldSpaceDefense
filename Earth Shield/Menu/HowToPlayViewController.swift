import UIKit

final class HowToPlayViewController: UIViewController {

    private struct Entry {
        let symbol: String
        let color: UIColor
        let title: String
        let body: String
    }

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private var headerBottom: NSLayoutYAxisAnchor!

    private let entries: [Entry] = [
        Entry(symbol: "globe.europe.africa.fill", color: UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1),
              title: "Defend the Planet",
              body: "Asteroids of fire and ice streak in from every direction toward the planet at the center of the screen."),
        Entry(symbol: "shield.lefthalf.filled", color: UIColor(red: 1.0, green: 0.5, blue: 0.25, alpha: 1),
              title: "Opposite Shields",
              body: "A fire shield and an ice shield orbit on opposite ends. Catch each asteroid with the OPPOSITE element: fire blocks ice, ice blocks fire."),
        Entry(symbol: "exclamationmark.triangle.fill", color: UIColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1),
              title: "Never Match",
              body: "If an asteroid hits a shield of the SAME element it detonates and the round ends. If it slips past into the planet you lose a shield."),
        Entry(symbol: "arrow.left.arrow.right", color: UIColor(red: 0.55, green: 0.8, blue: 1.0, alpha: 1),
              title: "Rotation Controls",
              body: "Hold the left and right buttons to swing the shields into place. The longer you survive, the faster they drift on their own."),
        Entry(symbol: "bolt.fill", color: UIColor(red: 1.0, green: 0.85, blue: 0.35, alpha: 1),
              title: "Build Combos",
              body: "Block asteroids back to back to raise your combo multiplier up to x6 and rack up far more points."),
        Entry(symbol: "sparkles", color: UIColor(red: 0.45, green: 1.0, blue: 0.6, alpha: 1),
              title: "Collect Power-Ups",
              body: "Catch drifting orbs with any shield: extra shields, slow motion, rotation stabilizers and instant score bursts."),
        Entry(symbol: "wave.3.right", color: UIColor(red: 1.0, green: 0.45, blue: 0.3, alpha: 1),
              title: "Unleash Pulse",
              body: "Every block charges the Pulse meter. When it is full, tap PULSE to wipe every asteroid on screen and earn bonus points.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.02, green: 0.03, blue: 0.08, alpha: 1)
        configureBackground()
        configureHeader()
        configureScroll()
        buildContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationCoordinator.lockToPortrait(for: self)
    }

    override var prefersStatusBarHidden: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    private func configureBackground() {
        let gradient = GradientView()
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.apply(colors: [
            UIColor(red: 0.05, green: 0.09, blue: 0.20, alpha: 1),
            UIColor(red: 0.01, green: 0.02, blue: 0.05, alpha: 1)
        ])
        view.addSubview(gradient)
        NSLayoutConstraint.activate([
            gradient.topAnchor.constraint(equalTo: view.topAnchor),
            gradient.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradient.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let glow = RadialGlowView(color: UIColor(red: 0.30, green: 0.55, blue: 1.0, alpha: 1))
        glow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(glow)
        NSLayoutConstraint.activate([
            glow.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.4),
            glow.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.4),
            glow.centerXAnchor.constraint(equalTo: view.leadingAnchor),
            glow.centerYAnchor.constraint(equalTo: view.topAnchor)
        ])
    }

    private func configureHeader() {
        let backButton = ClosureButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.setTitle(" Menu", for: .normal)
        backButton.tintColor = .white
        backButton.setTitleColor(.white, for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.onTap = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.text = "How to Play"
        titleLabel.font = .systemFont(ofSize: 26, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        headerBottom = titleLabel.bottomAnchor
    }

    private func configureScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerBottom, constant: 16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    private func buildContent() {
        for entry in entries {
            contentStack.addArrangedSubview(makeCard(for: entry))
        }
    }

    private func makeCard(for entry: Entry) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(white: 0.09, alpha: 0.92)
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = entry.color.withAlphaComponent(0.4).cgColor

        let iconBackground = UIView()
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = entry.color.withAlphaComponent(0.2)
        iconBackground.layer.cornerRadius = 26

        let icon = UIImageView(image: UIImage(systemName: entry.symbol))
        icon.tintColor = entry.color
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.addSubview(icon)

        let titleLabel = UILabel()
        titleLabel.text = entry.title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white

        let bodyLabel = UILabel()
        bodyLabel.text = entry.body
        bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = UIColor(white: 0.72, alpha: 1)
        bodyLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconBackground)
        card.addSubview(textStack)

        NSLayoutConstraint.activate([
            iconBackground.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconBackground.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconBackground.widthAnchor.constraint(equalToConstant: 52),
            iconBackground.heightAnchor.constraint(equalToConstant: 52),
            icon.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 28),

            textStack.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            textStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            textStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }
}
