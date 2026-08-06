import Foundation

final class AccessViewModel {

    enum Route {
        case remoteContent(address: String, requestReview: Bool)
        case game
    }

    private let storage = AccessStorage.shared
    private let service = AccessService()

    func decideRoute(completion: @escaping (Route) -> Void) {
        if storage.hasStoredPass, let destination = storage.destination {
            let shouldReview = !storage.reviewAlreadyRequested
            if shouldReview { storage.reviewAlreadyRequested = true }
            completion(.remoteContent(address: destination, requestReview: shouldReview))
            return
        }

        service.resolve { [weak self] outcome in
            switch outcome {
            case .granted(let pass, let destination):
                self?.storage.save(pass: pass, destination: destination)
                completion(.remoteContent(address: destination, requestReview: false))
            case .openApp:
                completion(.game)
            }
        }
    }
}
