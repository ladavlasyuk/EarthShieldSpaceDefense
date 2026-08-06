import UIKit

final class StatisticsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private var headerBottom: NSLayoutYAxisAnchor!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.02, green: 0.03, blue: 0.08, alpha: 1)
        configureBackground()
        configureHeader()
        configureScroll()
        rebuild()
    }

    private func configureBackground() {
        let gradient = GradientView()
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.apply(colors: [
            UIColor(red: 0.06, green: 0.07, blue: 0.16, alpha: 1),
            UIColor(red: 0.01, green: 0.02, blue: 0.05, alpha: 1)
        ])
        view.addSubview(gradient)
        NSLayoutConstraint.activate([
            gradient.topAnchor.constraint(equalTo: view.topAnchor),
            gradient.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradient.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let glow = RadialGlowView(color: UIColor(red: 0.45, green: 0.4, blue: 1.0, alpha: 1))
        glow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(glow)
        NSLayoutConstraint.activate([
            glow.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.5),
            glow.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.5),
            glow.centerXAnchor.constraint(equalTo: view.leadingAnchor),
            glow.centerYAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationCoordinator.lockToPortrait(for: self)
    }

    override var prefersStatusBarHidden: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

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
        titleLabel.text = "Statistics"
        titleLabel.font = .systemFont(ofSize: 26, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let resetButton = ClosureButton(type: .system)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1), for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.onTap = { [weak self] in self?.confirmReset() }
        view.addSubview(resetButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            resetButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        headerBottom = titleLabel.bottomAnchor
    }

    private func configureScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
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

    private func rebuild() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStack.addArrangedSubview(makeSummaryCard())
        for level in LevelCatalog.levels {
            let stats = StatisticsStore.shared.statistics(for: level.id)
            contentStack.addArrangedSubview(makeLevelCard(level: level, stats: stats))
        }
    }

    private func makeSummaryCard() -> UIView {
        let all = StatisticsStore.shared.allStatistics()
        let totalGames = all.reduce(0) { $0 + $1.gamesPlayed }
        let totalBlocked = all.reduce(0) { $0 + $1.totalBlocked }
        let totalMissed = all.reduce(0) { $0 + $1.totalMissed }
        let totalExplosions = all.reduce(0) { $0 + $1.totalExplosions }
        let totalPowerUps = all.reduce(0) { $0 + $1.powerUpsCollected }
        let totalPulses = all.reduce(0) { $0 + $1.pulsesUsed }

        let card = makeCardContainer(borderColor: UIColor.white.withAlphaComponent(0.2))
        let stack = cardStack(in: card)

        stack.addArrangedSubview(makeTitle("Overall"))
        stack.addArrangedSubview(makeRow("Total Games", "\(totalGames)"))
        stack.addArrangedSubview(makeRow("Total Blocked", "\(totalBlocked)"))
        stack.addArrangedSubview(makeRow("Total Missed", "\(totalMissed)"))
        stack.addArrangedSubview(makeRow("Total Explosions", "\(totalExplosions)"))
        stack.addArrangedSubview(makeRow("Total Power-Ups", "\(totalPowerUps)"))
        stack.addArrangedSubview(makeRow("Total Pulses", "\(totalPulses)"))
        return card
    }

    private func makeLevelCard(level: LevelConfiguration, stats: LevelStatistics) -> UIView {
        let card = makeCardContainer(borderColor: level.palette.accent.withAlphaComponent(0.5))
        let stack = cardStack(in: card)

        let dot = UIView()
        dot.backgroundColor = level.palette.accent
        dot.layer.cornerRadius = 7
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 14).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 14).isActive = true

        let name = makeTitle("\(level.id). \(level.name)")
        let titleRow = UIStackView(arrangedSubviews: [dot, name])
        titleRow.axis = .horizontal
        titleRow.spacing = 10
        titleRow.alignment = .center
        stack.addArrangedSubview(titleRow)

        stack.addArrangedSubview(makeRow("Games Played", "\(stats.gamesPlayed)"))
        stack.addArrangedSubview(makeRow("High Score", "\(stats.highScore)"))
        stack.addArrangedSubview(makeRow("Last Score", "\(stats.lastScore)"))
        stack.addArrangedSubview(makeRow("Best Survival", GameViewController.format(stats.bestSurvivalTime)))
        stack.addArrangedSubview(makeRow("Last Survival", GameViewController.format(stats.lastSurvivalTime)))
        stack.addArrangedSubview(makeRow("Best Combo", "x\(stats.bestCombo)"))
        stack.addArrangedSubview(makeRow("Blocked", "\(stats.totalBlocked)"))
        stack.addArrangedSubview(makeRow("Missed", "\(stats.totalMissed)"))
        stack.addArrangedSubview(makeRow("Explosions", "\(stats.totalExplosions)"))
        stack.addArrangedSubview(makeRow("Power-Ups", "\(stats.powerUpsCollected)"))
        stack.addArrangedSubview(makeRow("Pulses Used", "\(stats.pulsesUsed)"))
        stack.addArrangedSubview(makeRow("Accuracy", String(format: "%.0f%%", stats.accuracy * 100)))
        stack.addArrangedSubview(makeRow("Last Played", format(stats.lastPlayed)))
        return card
    }

    private func makeCardContainer(borderColor: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(white: 0.09, alpha: 0.92)
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = borderColor.cgColor
        card.layer.shadowColor = borderColor.cgColor
        card.layer.shadowOpacity = 0.35
        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        return card
    }

    private func cardStack(in card: UIView) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18)
        ])
        return stack
    }

    private func makeTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 20, weight: .heavy)
        label.textColor = .white
        return label
    }

    private func makeRow(_ name: String, _ value: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .equalSpacing

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 15, weight: .regular)
        nameLabel.textColor = UIColor(white: 0.65, alpha: 1)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 15, weight: .bold)
        valueLabel.textColor = .white

        row.addArrangedSubview(nameLabel)
        row.addArrangedSubview(valueLabel)
        return row
    }

    private func format(_ date: Date?) -> String {
        guard let date else { return "—" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func confirmReset() {
        let alert = UIAlertController(title: "Reset Statistics", message: "All progress will be erased.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            StatisticsStore.shared.resetAll()
            self?.rebuild()
        })
        present(alert, animated: true)
    }
}
