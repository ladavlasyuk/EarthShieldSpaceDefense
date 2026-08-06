import UIKit
import SpriteKit

final class GameViewController: UIViewController {

    private let level: LevelConfiguration
    private var viewModel: GameViewModel!
    private var scene: GameScene!

    private let skView = SKView()
    private let scoreLabel = GameViewController.makeHUDLabel(alignment: .left)
    private let timeLabel = GameViewController.makeHUDLabel(alignment: .center)
    private let livesLabel = GameViewController.makeHUDLabel(alignment: .right)

    private let leftButton = StyledButton(type: .custom)
    private let rightButton = StyledButton(type: .custom)
    private let pauseButton = UIButton(type: .system)
    private let pulseButton = StyledButton(type: .custom)
    private let comboLabel = UILabel()
    private let toastLabel = UILabel()

    private let pulseTrackLayer = CAShapeLayer()
    private let pulseChargeLayer = CAShapeLayer()
    private var pulseReady = false
    private var sessionStarted = false

    private var overlayView: UIView?

    init(level: LevelConfiguration) {
        self.level = level
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSceneView()
        configureHUD()
        configureControls()
        configureSpecials()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPulseRing()
        if !sessionStarted, skView.bounds.width > 0, skView.bounds.height > 0 {
            sessionStarted = true
            startSession()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationCoordinator.lockToPortrait(for: self)
    }

    override var prefersStatusBarHidden: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    private func configureSceneView() {
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.ignoresSiblingOrder = true
        view.addSubview(skView)
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: view.topAnchor),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func configureHUD() {
        let stack = UIStackView(arrangedSubviews: [scoreLabel, timeLabel, livesLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        pauseButton.tintColor = .white
        pauseButton.contentVerticalAlignment = .fill
        pauseButton.contentHorizontalAlignment = .fill
        pauseButton.addTarget(self, action: #selector(didTapPause), for: .touchUpInside)
        view.addSubview(pauseButton)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pauseButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 12),
            pauseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pauseButton.widthAnchor.constraint(equalToConstant: 34),
            pauseButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    private func configureControls() {
        configureDirectionButton(leftButton, symbol: "arrow.counterclockwise")
        configureDirectionButton(rightButton, symbol: "arrow.clockwise")

        leftButton.addTarget(self, action: #selector(rotateLeftDown), for: .touchDown)
        leftButton.addTarget(self, action: #selector(rotateUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        rightButton.addTarget(self, action: #selector(rotateRightDown), for: .touchDown)
        rightButton.addTarget(self, action: #selector(rotateUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])

        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            leftButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            leftButton.widthAnchor.constraint(equalToConstant: 96),
            leftButton.heightAnchor.constraint(equalToConstant: 96),

            rightButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),
            rightButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            rightButton.widthAnchor.constraint(equalToConstant: 96),
            rightButton.heightAnchor.constraint(equalToConstant: 96)
        ])
    }

    private func configureDirectionButton(_ button: StyledButton, symbol: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.apply(
            colors: [level.palette.accent.lighter(by: 0.1), level.palette.accent.darker(by: 0.2)],
            cornerRadius: 48,
            glowColor: level.palette.accent
        )
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        button.layer.borderWidth = 2
        let configuration = UIImage.SymbolConfiguration(pointSize: 36, weight: .heavy)
        button.setImage(UIImage(systemName: symbol, withConfiguration: configuration), for: .normal)
        button.tintColor = .white
        view.addSubview(button)
    }

    private func configureSpecials() {
        pulseButton.translatesAutoresizingMaskIntoConstraints = false
        pulseButton.setTitle("PULSE", for: .normal)
        pulseButton.setTitleColor(.white, for: .normal)
        pulseButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .heavy)
        pulseButton.apply(
            colors: [level.palette.fire.lighter(by: 0.1), level.palette.fire.darker(by: 0.2)],
            cornerRadius: 42,
            glowColor: level.palette.fire
        )
        pulseButton.addTarget(self, action: #selector(didTapPulse), for: .touchUpInside)
        view.addSubview(pulseButton)

        pulseTrackLayer.fillColor = UIColor.clear.cgColor
        pulseTrackLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        pulseTrackLayer.lineWidth = 4
        pulseChargeLayer.fillColor = UIColor.clear.cgColor
        pulseChargeLayer.strokeColor = level.palette.accent.cgColor
        pulseChargeLayer.lineWidth = 4
        pulseChargeLayer.lineCap = .round
        pulseChargeLayer.strokeEnd = 0
        pulseButton.layer.addSublayer(pulseTrackLayer)
        pulseButton.layer.addSublayer(pulseChargeLayer)

        comboLabel.translatesAutoresizingMaskIntoConstraints = false
        comboLabel.textColor = .white
        comboLabel.font = .systemFont(ofSize: 24, weight: .heavy)
        comboLabel.textAlignment = .center
        comboLabel.alpha = 0
        comboLabel.layer.shadowColor = UIColor.black.cgColor
        comboLabel.layer.shadowOpacity = 0.6
        comboLabel.layer.shadowRadius = 4
        comboLabel.layer.shadowOffset = .zero
        view.addSubview(comboLabel)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.textColor = .white
        toastLabel.font = .systemFont(ofSize: 18, weight: .bold)
        toastLabel.textAlignment = .center
        toastLabel.alpha = 0
        toastLabel.layer.shadowColor = UIColor.black.cgColor
        toastLabel.layer.shadowOpacity = 0.7
        toastLabel.layer.shadowRadius = 4
        toastLabel.layer.shadowOffset = .zero
        view.addSubview(toastLabel)

        NSLayoutConstraint.activate([
            pulseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pulseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            pulseButton.widthAnchor.constraint(equalToConstant: 84),
            pulseButton.heightAnchor.constraint(equalToConstant: 84),

            comboLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comboLabel.bottomAnchor.constraint(equalTo: leftButton.topAnchor, constant: -18),

            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110)
        ])
        updatePulseVisual(ready: false)
    }

    private func layoutPulseRing() {
        let inset: CGFloat = 4
        let rect = pulseButton.bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(
            arcCenter: CGPoint(x: pulseButton.bounds.midX, y: pulseButton.bounds.midY),
            radius: rect.width / 2,
            startAngle: -.pi / 2,
            endAngle: .pi * 1.5,
            clockwise: true
        ).cgPath
        pulseTrackLayer.path = path
        pulseChargeLayer.path = path
    }

    private func startSession() {
        overlayView?.removeFromSuperview()
        overlayView = nil

        viewModel = GameViewModel(level: level)
        bindViewModel()

        let newScene = GameScene(size: skView.bounds.size)
        newScene.scaleMode = .resizeFill
        newScene.viewModel = viewModel
        scene = newScene
        skView.presentScene(newScene)

        updateScore(0)
        updateLives(viewModel.lives)
        updateTime(0)
        comboLabel.alpha = 0
        toastLabel.alpha = 0
        pulseChargeLayer.strokeEnd = 0
        updatePulseVisual(ready: false)
    }

    private func bindViewModel() {
        viewModel.onScoreChanged = { [weak self] score in self?.updateScore(score) }
        viewModel.onLivesChanged = { [weak self] lives in self?.updateLives(lives) }
        viewModel.onTimeChanged = { [weak self] time in self?.updateTime(time) }
        viewModel.onComboChanged = { [weak self] combo, multiplier in self?.updateCombo(combo, multiplier) }
        viewModel.onPulseChargeChanged = { [weak self] charge in self?.updatePulse(charge) }
        viewModel.onPowerUpCollected = { [weak self] kind in self?.showToast(kind) }
        viewModel.onGameOver = { [weak self] result in self?.presentGameOver(result) }
    }

    private func updateScore(_ score: Int) {
        scoreLabel.text = "Score\n\(score)"
    }

    private func updateLives(_ lives: Int) {
        livesLabel.text = "Shields\n\(String(repeating: "♥", count: max(lives, 0)))"
    }

    private func updateTime(_ time: TimeInterval) {
        timeLabel.text = "Time\n\(Self.format(time))"
    }

    private func updateCombo(_ combo: Int, _ multiplier: Int) {
        guard combo >= 2 else {
            UIView.animate(withDuration: 0.2) { self.comboLabel.alpha = 0 }
            return
        }
        comboLabel.text = "COMBO x\(multiplier)"
        comboLabel.textColor = multiplier >= 4 ? level.palette.accent : .white
        comboLabel.alpha = 1
        comboLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6) {
            self.comboLabel.transform = .identity
        }
    }

    private func updatePulse(_ charge: CGFloat) {
        pulseChargeLayer.strokeEnd = charge
        let ready = charge >= 1.0
        if ready != pulseReady {
            updatePulseVisual(ready: ready)
        }
    }

    private func updatePulseVisual(ready: Bool) {
        pulseReady = ready
        pulseButton.isEnabled = ready
        if ready {
            pulseButton.alpha = 1
            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.fromValue = 1.0
            pulse.toValue = 1.08
            pulse.duration = 0.6
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            pulseButton.layer.add(pulse, forKey: "readyPulse")
        } else {
            pulseButton.alpha = 0.5
            pulseButton.layer.removeAnimation(forKey: "readyPulse")
        }
    }

    private func showToast(_ kind: PowerUpKind) {
        toastLabel.text = kind.title.uppercased()
        toastLabel.textColor = kind.color
        toastLabel.layer.removeAllAnimations()
        toastLabel.alpha = 0
        toastLabel.transform = CGAffineTransform(translationX: 0, y: 12)
        UIView.animate(withDuration: 0.25, animations: {
            self.toastLabel.alpha = 1
            self.toastLabel.transform = .identity
        }, completion: { _ in
            UIView.animate(withDuration: 0.35, delay: 0.9, options: []) {
                self.toastLabel.alpha = 0
            }
        })
    }

    @objc private func didTapPulse() {
        guard let scene, viewModel.isPulseReady else { return }
        let cleared = scene.detonatePulse()
        viewModel.usePulse(clearedCount: cleared)
    }

    @objc private func rotateLeftDown() {
        scene?.rotationInput = -1
    }

    @objc private func rotateRightDown() {
        scene?.rotationInput = 1
    }

    @objc private func rotateUp() {
        scene?.rotationInput = 0
    }

    @objc private func didTapPause() {
        guard overlayView == nil else { return }
        skView.isPaused = true
        presentPauseMenu()
    }

    private func presentPauseMenu() {
        let panel = OverlayPanel(
            title: "Paused",
            message: level.name,
            accent: level.palette.accent
        )
        panel.addAction(title: "Resume") { [weak self] in
            self?.dismissOverlay()
            self?.skView.isPaused = false
        }
        panel.addAction(title: "Quit to Levels", style: .secondary) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        showOverlay(panel)
    }

    private func presentGameOver(_ result: GameResult) {
        let stats = StatisticsStore.shared.statistics(for: level.id)
        let panel = OverlayPanel(
            title: "Planet Lost",
            message: level.name,
            accent: level.palette.accent
        )
        panel.addStat("Score", "\(result.score)")
        panel.addStat("Survived", Self.format(result.survivalTime))
        panel.addStat("Best Combo", "x\(result.bestCombo)")
        panel.addStat("Blocked", "\(result.blocked)")
        panel.addStat("Power-Ups", "\(result.powerUpsCollected)")
        panel.addStat("Pulses", "\(result.pulsesUsed)")
        panel.addStat("Best Score", "\(stats.highScore)")
        panel.addAction(title: "Play Again") { [weak self] in
            self?.startSession()
        }
        panel.addAction(title: "Levels", style: .secondary) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        showOverlay(panel)
    }

    private func showOverlay(_ panel: UIView) {
        let backdrop = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdrop)

        panel.translatesAutoresizingMaskIntoConstraints = false
        backdrop.contentView.addSubview(panel)

        NSLayoutConstraint.activate([
            backdrop.topAnchor.constraint(equalTo: view.topAnchor),
            backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panel.centerXAnchor.constraint(equalTo: backdrop.contentView.centerXAnchor),
            panel.centerYAnchor.constraint(equalTo: backdrop.contentView.centerYAnchor),
            panel.leadingAnchor.constraint(equalTo: backdrop.contentView.leadingAnchor, constant: 32),
            panel.trailingAnchor.constraint(equalTo: backdrop.contentView.trailingAnchor, constant: -32)
        ])

        panel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        panel.alpha = 0
        backdrop.alpha = 0
        UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.4) {
            backdrop.alpha = 1
            panel.alpha = 1
            panel.transform = .identity
        }
        overlayView = backdrop
    }

    private func dismissOverlay() {
        overlayView?.removeFromSuperview()
        overlayView = nil
    }

    private static func makeHUDLabel(alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = alignment
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.6
        label.layer.shadowRadius = 4
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }

    static func format(_ time: TimeInterval) -> String {
        let total = Int(time)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
