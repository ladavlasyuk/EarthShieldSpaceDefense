import UIKit

enum OrientationCoordinator {

    static var allowedMask: UIInterfaceOrientationMask = .portrait

    static func lockToPortrait(for controller: UIViewController) {
        apply(.portrait, for: controller)
    }

    static func allowAllExceptUpsideDown(for controller: UIViewController) {
        apply(.allButUpsideDown, for: controller)
    }

    private static func apply(_ mask: UIInterfaceOrientationMask, for controller: UIViewController) {
        allowedMask = mask
        let geometry = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: mask)
        controller.view.window?.windowScene?.requestGeometryUpdate(geometry) { _ in }
        controller.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}
