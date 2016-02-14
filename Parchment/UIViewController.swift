import UIKit

extension UIViewController {
  
  func addViewController(viewController: UIViewController) {
    addChildViewController(viewController)
    view.addSubview(viewController.view)
    viewController.didMoveToParentViewController(self)
  }
  
}
