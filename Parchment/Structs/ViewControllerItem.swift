import UIKit

public struct ViewControllerItem: PagingTitleItem, Equatable {
  
  public let viewController: UIViewController
  public let title: String
  
  init(viewController: UIViewController) {
    self.viewController = viewController
    self.title = viewController.title ?? ""
  }
}

public func ==(lhs: ViewControllerItem, rhs: ViewControllerItem) -> Bool {
  return lhs.viewController == rhs.viewController
}
