import UIKit
import WebKit
import StoreKit

final class RemoteContentViewController: UIViewController {

    private let destination: String
    private let shouldRequestReview: Bool
    private var firstRenderFinished = false

    private var contentView: WKWebView!
    private let overlay = LoadingOverlayView()

    init(destination: String, requestReview: Bool) {
        self.destination = destination
        self.shouldRequestReview = requestReview
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true

        contentView = WKWebView(frame: .zero, configuration: configuration)
        contentView.navigationDelegate = self
        contentView.scrollView.contentInsetAdjustmentBehavior = .never
        contentView.allowsBackForwardNavigationGestures = true
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        loadDestination()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationCoordinator.allowAllExceptUpsideDown(for: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestReviewIfNeeded()
    }

    override var prefersStatusBarHidden: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .allButUpsideDown }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }

    private func loadDestination() {
        guard let address = URL(string: destination) else {
            overlay.endAnimating()
            overlay.isHidden = true
            return
        }
        var request = URLRequest(url: address)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        contentView.load(request)
    }

    private func requestReviewIfNeeded() {
        guard shouldRequestReview else { return }
        guard let scene = view.window?.windowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }

    private func dismissOverlay() {
        guard !firstRenderFinished else { return }
        firstRenderFinished = true
        overlay.endAnimating()
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.overlay.alpha = 0
        }, completion: { [weak self] _ in
            self?.overlay.isHidden = true
        })
    }
}

extension RemoteContentViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        dismissOverlay()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        dismissOverlay()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        dismissOverlay()
    }
}
