import UIKit

enum ElementKind: CaseIterable {
    case fire
    case ice

    var opposite: ElementKind {
        switch self {
        case .fire: return .ice
        case .ice: return .fire
        }
    }
}
