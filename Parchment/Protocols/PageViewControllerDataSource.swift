import UIKit

public protocol PageViewControllerDataSource: class {
  func pageViewController(
    _ pageViewController: PageViewController,
    viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
  func pageViewController(
    _ pageViewController: PageViewController,
    viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
}
