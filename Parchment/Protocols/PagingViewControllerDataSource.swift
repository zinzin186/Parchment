import UIKit

public protocol PagingViewControllerDataSource: class {
  func numberOfItems() -> Int
  func titleForIndex(index: Int) -> String?
  func indexOfViewController(viewController: UIViewController) -> Int?
  func viewControllerAtIndex(index: Int) -> UIViewController?
}
