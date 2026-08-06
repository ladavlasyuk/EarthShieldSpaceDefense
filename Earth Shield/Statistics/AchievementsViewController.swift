import UIKit

final class AchievementsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private var headerBottom: NSLayoutYAxisAnchor!

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
            UIColor(red: 0.08, green: 0.07, blue: 0.04, alpha: 1),
            UIColor(red: 0.02, green: 0.02, blue: 0.04, alpha: 1)
        ])
        view.addSubview(gradient)
        NSLayoutConstraint.activate([
            gradient.topAnchor.constraint(equalTo: view.topAnchor),
            gradient.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradient.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let glow = RadialGlowView(color: UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1))
        glow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(glow)
        NSLayoutConstraint.activate([
            glow.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.4),
            glow.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.4),
            glow.centerXAnchor.constraint(equalTo: view.trailingAnchor),
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
        titleLabel.text = "Achievements"
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
        let achievements = AchievementsProvider.evaluate()
        let unlocked = achievements.filter(\.isUnlocked).count

        let summary = UILabel()
        summary.text = "\(unlocked) of \(achievements.count) unlocked"
        summary.font = .systemFont(ofSize: 15, weight: .semibold)
        summary.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1)
        contentStack.addArrangedSubview(summary)

        for achievement in achievements {
            contentStack.addArrangedSubview(makeCard(for: achievement))
        }
    }

    private func makeCard(for achievement: Achievement) -> UIView {
        let accent = achievement.isUnlocked
            ? UIColor(red: 1.0, green: 0.82, blue: 0.35, alpha: 1)
            : UIColor(white: 0.45, alpha: 1)

        let card = UIView()
        card.backgroundColor = UIColor(white: 0.09, alpha: 0.92)
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = accent.withAlphaComponent(0.5).cgColor
        if achievement.isUnlocked {
            card.layer.shadowColor = accent.cgColor
            card.layer.shadowOpacity = 0.35
            card.layer.shadowRadius = 12
            card.layer.shadowOffset = CGSize(width: 0, height: 6)
        }

        let iconBackground = UIView()
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = accent.withAlphaComponent(achievement.isUnlocked ? 0.22 : 0.12)
        iconBackground.layer.cornerRadius = 26

        let icon = UIImageView(image: UIImage(systemName: achievement.symbolName))
        icon.tintColor = accent
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.addSubview(icon)

        let titleLabel = UILabel()
        titleLabel.text = achievement.title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white

        let detailLabel = UILabel()
        detailLabel.text = achievement.detail
        detailLabel.font = .systemFont(ofSize: 13, weight: .medium)
        detailLabel.textColor = UIColor(white: 0.65, alpha: 1)
        detailLabel.numberOfLines = 0

        let progressTrack = UIView()
        progressTrack.backgroundColor = UIColor(white: 0.2, alpha: 1)
        progressTrack.layer.cornerRadius = 3
        progressTrack.translatesAutoresizingMaskIntoConstraints = false

        let progressFill = UIView()
        progressFill.backgroundColor = accent
        progressFill.layer.cornerRadius = 3
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressTrack.addSubview(progressFill)

        let progressLabel = UILabel()
        progressLabel.text = achievement.isUnlocked
            ? "Completed"
            : "\(min(achievement.current, achievement.target)) / \(achievement.target)"
        progressLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        progressLabel.textColor = accent

        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel, progressTrack, progressLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.setCustomSpacing(10, after: detailLabel)
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let badge = UIImageView(image: UIImage(systemName: achievement.isUnlocked ? "checkmark.seal.fill" : "lock.fill"))
        badge.tintColor = accent
        badge.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconBackground)
        card.addSubview(textStack)
        card.addSubview(badge)

        NSLayoutConstraint.activate([
            iconBackground.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconBackground.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconBackground.widthAnchor.constraint(equalToConstant: 52),
            iconBackground.heightAnchor.constraint(equalToConstant: 52),
            icon.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 28),

            badge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            badge.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            badge.widthAnchor.constraint(equalToConstant: 22),
            badge.heightAnchor.constraint(equalToConstant: 22),

            textStack.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: badge.leadingAnchor, constant: -10),
            textStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            textStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),

            progressTrack.heightAnchor.constraint(equalToConstant: 6),
            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressTrack.widthAnchor, multiplier: max(0.02, achievement.progress))
        ])

        return card
    }
}
