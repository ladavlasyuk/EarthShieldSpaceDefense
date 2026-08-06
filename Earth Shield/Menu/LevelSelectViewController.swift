import UIKit

final class LevelSelectViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.02, green: 0.03, blue: 0.08, alpha: 1)
        configureBackground()
        configureHeader()
        configureScroll()
        buildCards()
    }

    private func configureBackground() {
        let gradient = GradientView()
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.apply(colors: [
            UIColor(red: 0.06, green: 0.08, blue: 0.18, alpha: 1),
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
            glow.centerXAnchor.constraint(equalTo: view.trailingAnchor),
            glow.centerYAnchor.constraint(equalTo: view.topAnchor)
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
        titleLabel.text = "Choose a Sector"
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

    private var headerBottom: NSLayoutYAxisAnchor!

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

    private func buildCards() {
        for level in LevelCatalog.levels {
            contentStack.addArrangedSubview(makeCard(for: level))
        }
    }

    private func makeCard(for level: LevelConfiguration) -> UIView {
        let wrapper = UIView()
        wrapper.heightAnchor.constraint(equalToConstant: 138).isActive = true
        wrapper.layer.shadowColor = level.palette.accent.cgColor
        wrapper.layer.shadowOpacity = 0.45
        wrapper.layer.shadowRadius = 14
        wrapper.layer.shadowOffset = CGSize(width: 0, height: 8)

        let card = ClosureButton(type: .custom)
        card.onTap = { [weak self] in self?.startLevel(level) }
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 22
        card.clipsToBounds = true
        wrapper.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: wrapper.topAnchor),
            card.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor)
        ])

        let gradient = GradientView()
        gradient.isUserInteractionEnabled = false
        gradient.apply(colors: [level.palette.planetInner, level.palette.planetOuter], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
        gradient.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(gradient)

        let sheen = GradientView()
        sheen.isUserInteractionEnabled = false
        sheen.apply(colors: [UIColor.white.withAlphaComponent(0.28), UIColor.white.withAlphaComponent(0.0)])
        sheen.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(sheen)

        let ring = UIView()
        ring.isUserInteractionEnabled = false
        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        ring.layer.borderWidth = 10
        ring.layer.cornerRadius = 70
        card.addSubview(ring)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor.white.withAlphaComponent(0.9)
        chevron.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chevron)

        let nameLabel = UILabel()
        nameLabel.text = "\(level.id). \(level.name)"
        nameLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        nameLabel.textColor = .white

        let subtitleLabel = UILabel()
        subtitleLabel.text = level.subtitle
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor(white: 1, alpha: 0.85)
        subtitleLabel.numberOfLines = 0

        let stats = StatisticsStore.shared.statistics(for: level.id)
        let bestLabel = UILabel()
        bestLabel.text = "Best \(stats.highScore)  •  Games \(stats.gamesPlayed)"
        bestLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        bestLabel.textColor = UIColor(white: 1, alpha: 0.95)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel, bestLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.isUserInteractionEnabled = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(textStack)

        NSLayoutConstraint.activate([
            gradient.topAnchor.constraint(equalTo: card.topAnchor),
            gradient.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            gradient.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            sheen.topAnchor.constraint(equalTo: card.topAnchor),
            sheen.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            sheen.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            sheen.heightAnchor.constraint(equalTo: card.heightAnchor, multiplier: 0.55),
            ring.widthAnchor.constraint(equalToConstant: 140),
            ring.heightAnchor.constraint(equalToConstant: 140),
            ring.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: 36),
            ring.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            textStack.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        return wrapper
    }

    private func startLevel(_ level: LevelConfiguration) {
        navigationController?.pushViewController(GameViewController(level: level), animated: true)
    }
}
