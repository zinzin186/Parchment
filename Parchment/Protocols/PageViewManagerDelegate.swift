import UIKit

protocol PageViewManagerDelegate: class {
  func scrollForward()
  func scrollReverse()
  func layoutViews(for viewControllers: [UIViewController])
  func addViewController(_ viewController: UIViewController)
  func removeViewController(_ viewController: UIViewController)
  func beginAppearanceTransition(isAppearing: Bool, viewController: UIViewController)
  func endAppearanceTransition(viewController: UIViewController)
  func willScroll(
    from selectedViewController: UIViewController,
    to destinationViewController: UIViewController)
  func isScrolling(
    from selectedViewController: UIViewController,
    to destinationViewController: UIViewController?,
    progress: CGFloat)
  func didFinishScrolling(
    from selectedViewController: UIViewController,
    to destinationViewController: UIViewController,
    transitionSuccessful: Bool)
}
