import Foundation

final class AccessStorage {

    static let shared = AccessStorage()

    private let defaults = UserDefaults.standard

    private enum Key {
        static let pass = "stored_pass_value"
        static let address = "stored_destination_value"
        static let firstReviewDone = "first_review_requested"
    }

    private init() {}

    var pass: String? {
        get { defaults.string(forKey: Key.pass) }
        set { defaults.set(newValue, forKey: Key.pass) }
    }

    var destination: String? {
        get { defaults.string(forKey: Key.address) }
        set { defaults.set(newValue, forKey: Key.address) }
    }

    var hasStoredPass: Bool {
        guard let pass else { return false }
        return !pass.isEmpty
    }

    var reviewAlreadyRequested: Bool {
        get { defaults.bool(forKey: Key.firstReviewDone) }
        set { defaults.set(newValue, forKey: Key.firstReviewDone) }
    }

    func save(pass: String, destination: String) {
        self.pass = pass
        self.destination = destination
    }
}
