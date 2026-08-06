import UIKit

final class LaunchViewController: UIViewController {

    private let viewModel: AccessViewModel
    private let overlay = LoadingOverlayView()
    private var didStart = false

    init(viewModel: AccessViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        overlay.frame = view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(overlay)
        OrientationCoordinator.allowedMask = .portrait
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didStart else { return }
        didStart = true
        resolveRoute()
    }

    override var prefersStatusBarHidden: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    private func resolveRoute() {
        viewModel.decideRoute { [weak self] route in
            self?.present(route)
        }
    }

    private func present(_ route: AccessViewModel.Route) {
        let destination: UIViewController
        switch route {
        case .remoteContent(let address, let requestReview):
            OrientationCoordinator.allowedMask = .allButUpsideDown
            destination = RemoteContentViewController(destination: address, requestReview: requestReview)
        case .game:
            OrientationCoordinator.allowedMask = .portrait
            let menu = MenuViewController()
            let navigation = UINavigationController(rootViewController: menu)
            navigation.isNavigationBarHidden = true
            destination = navigation
        }
        swapRoot(to: destination)
    }

    private func swapRoot(to controller: UIViewController) {
        guard let window = view.window ?? UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first
        else {
            return
        }

        window.rootViewController = controller
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
    }
}
