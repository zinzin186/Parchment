import UIKit

public protocol PageViewControllerDelegate: class {
  func pageViewController(
    _  pageViewController: PageViewController,
    willStartScrollingFrom startingViewController: UIViewController,
    destinationViewController: UIViewController)
  func pageViewController(
    _  pageViewController: PageViewController,
    isScrollingFrom startingViewController: UIViewController,
    destinationViewController: UIViewController?,
    progress: CGFloat)
  func pageViewController(
    _  pageViewController: PageViewController,
    didFinishScrollingFrom startingViewController: UIViewController,
    destinationViewController: UIViewController,
    transitionSuccessful: Bool)
}
