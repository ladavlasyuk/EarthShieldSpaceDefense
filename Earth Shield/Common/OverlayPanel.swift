import UIKit

final class OverlayPanel: UIView {

    enum ActionStyle {
        case primary
        case secondary
    }

    private let accent: UIColor
    private let stack = UIStackView()

    init(title: String, message: String, accent: UIColor) {
        self.accent = accent
        super.init(frame: .zero)
        configure(title: title, message: message)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(title: String, message: String) {
        backgroundColor = UIColor(white: 0.10, alpha: 0.97)
        layer.cornerRadius = 26
        layer.borderWidth = 1
        layer.borderColor = accent.withAlphaComponent(0.5).cgColor
        layer.shadowColor = accent.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 26
        layer.shadowOffset = CGSize(width: 0, height: 12)

        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 28, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 15, weight: .medium)
        messageLabel.textColor = accent
        messageLabel.textAlignment = .center
        stack.addArrangedSubview(messageLabel)
    }

    func addStat(_ name: String, _ value: String) {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .equalSpacing

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 16, weight: .regular)
        nameLabel.textColor = UIColor(white: 0.7, alpha: 1)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        valueLabel.textColor = .white

        row.addArrangedSubview(nameLabel)
        row.addArrangedSubview(valueLabel)
        stack.addArrangedSubview(row)
    }

    func addAction(title: String, style: ActionStyle = .primary, handler: @escaping () -> Void) {
        let button = StyledButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true

        switch style {
        case .primary:
            button.apply(
                colors: [accent.lighter(by: 0.12), accent.darker(by: 0.12)],
                cornerRadius: 16,
                glowColor: accent
            )
            button.setTitleColor(.black, for: .normal)
        case .secondary:
            button.apply(
                colors: [UIColor(white: 0.2, alpha: 0.9), UIColor(white: 0.12, alpha: 0.9)],
                cornerRadius: 16
            )
            button.layer.borderWidth = 1
            button.layer.borderColor = accent.withAlphaComponent(0.6).cgColor
            button.setTitleColor(.white, for: .normal)
        }

        button.onTap = handler
        stack.addArrangedSubview(button)
    }
}

class ClosureButton: UIButton {
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        addTarget(self, action: #selector(pressDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    @objc private func handleTap() {
        onTap?()
    }

    @objc private func pressDown() {
        UIView.animate(withDuration: 0.08) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.alpha = 0.9
        }
    }

    @objc private func pressUp() {
        UIView.animate(withDuration: 0.18, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.transform = .identity
            self.alpha = 1
        }
    }
}
