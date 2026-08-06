import UIKit

struct DeviceInfoProvider {

    var operatingSystem: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }

    var language: String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.components(separatedBy: "-").first ?? preferred
    }

    var hardwareModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce(into: "") { partial, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            partial.append(Character(UnicodeScalar(UInt8(value))))
        }
        return identifier
    }

    var country: String {
        if #available(iOS 16.0, *) {
            return Locale.current.region?.identifier ?? "US"
        } else {
            return (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US"
        }
    }
}
