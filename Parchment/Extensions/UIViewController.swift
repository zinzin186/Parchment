import UIKit

extension UIViewController {
  
  func addViewController(viewController: UIViewController) {
    addChildViewController(viewController)
    view.addSubview(viewController.view)
    viewController.didMoveToParentViewController(self)
  }
  
  func removeViewController(viewController: UIViewController) {
    viewController.removeFromParentViewController()
    viewController.view.removeFromSuperview()
    viewController.didMoveToParentViewController(nil)
  }
  
}
