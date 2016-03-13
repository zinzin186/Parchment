import UIKit
import Cartography

protocol PagingContentViewControllerDelegate: class {
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didChangeOffset: CGFloat)
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didMoveToIndex: Int)
}

class PagingContentViewController: UIViewController {
  
  var state: PagingState
  weak var delegate: PagingContentViewControllerDelegate?
  private let dataSource: PagingViewControllerDataSource
  private let pageViewController: UIPageViewController
  
  private var pendingViewController: UIViewController?
  private var upcomingViewController: UIViewController?
  
  init(dataSource: PagingViewControllerDataSource, state: PagingState) {
    
    self.state = state
    self.dataSource = dataSource
    self.pageViewController = UIPageViewController(
      transitionStyle: .Scroll,
      navigationOrientation: .Horizontal,
      options: nil)
    
    super.init(nibName: nil, bundle: nil)
    
    pageViewController.dataSource = self
    pageViewController.delegate = self
    pageViewController.view.subviews.forEach {
      if let scrollView = $0 as? UIScrollView {
        scrollView.delegate = self
      }
    }
  }

  required init?(coder: NSCoder) {
    fatalError(InitCoderError)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addViewController(pageViewController)
    constrain(pageViewController.view, view) { pageView, view in
      pageView.edges == view.edges
    }
  }
  
  func setViewControllerForIndex(index: Int, direction: PagingDirection, animated: Bool) {
    guard let viewController = dataSource.viewControllerAtIndex(index) else { return }
    pageViewController.setViewControllers([viewController],
      direction: direction.pageViewControllerNavigationDirection,
      animated: animated,
      completion: { completed in
        if completed {
          self.delegate?.pagingContentViewController(self, didMoveToIndex: index)
        }
    })
  }
  
}

extension PagingContentViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let offset = CGFloat(scrollView.contentOffset.x / scrollView.bounds.width) - 1
    delegate?.pagingContentViewController(self, didChangeOffset: offset)
  }
  
}

extension PagingContentViewController: UIPageViewControllerDelegate {
 
  func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
    if let viewController = pendingViewControllers.first {
      pendingViewController = viewController
    }
  }
  
  func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard
      let viewController = pendingViewController,
      let index = dataSource.indexOfViewController(viewController) else { return }
    
    if completed {
      delegate?.pagingContentViewController(self, didMoveToIndex: index)
    }
    
    pendingViewController = nil
  }
  
}

extension PagingContentViewController: UIPageViewControllerDataSource {
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    guard let index = dataSource.indexOfViewController(viewController) else { return nil }
    if index > 0 {
      return dataSource.viewControllerAtIndex(index - 1)
    }
    return nil
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    guard let index = dataSource.indexOfViewController(viewController) else { return nil }
    if index < dataSource.numberOfItems() - 1 {
      return dataSource.viewControllerAtIndex(index + 1)
    }
    return nil
  }
  
}
