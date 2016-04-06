import UIKit

protocol PagingContentViewControllerDelegate: class {
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didChangeOffset: CGFloat)
  func pagingContentViewControllerDidCompleteTransition(pagingContentViewController: PagingContentViewController)
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didBeginDraggingInDirection: PagingDirection)
}

public class PagingContentViewController: UIViewController {
  
  weak var delegate: PagingContentViewControllerDelegate?
  let pageViewController: UIPageViewController
  
  init() {
    
    pageViewController = UIPageViewController(
      transitionStyle: .Scroll,
      navigationOrientation: .Horizontal,
      options: nil)
    
    super.init(nibName: nil, bundle: nil)
    
    pageViewController.delegate = self
    pageViewController.view.subviews.forEach {
      if let scrollView = $0 as? UIScrollView {
        scrollView.delegate = self
      }
    }
  }

  public required init?(coder: NSCoder) {
    fatalError(InitCoderError)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    addViewController(pageViewController)
    view.addConstraintsForFullscreenSubview(pageViewController.view)
  }
  
  func setViewController(viewController: UIViewController, direction: PagingDirection, animated: Bool) {
    pageViewController.setViewControllers([viewController],
      direction: direction.pageViewControllerNavigationDirection,
      animated: animated,
      completion: { completed in
        if completed {
          self.delegate?.pagingContentViewControllerDidCompleteTransition(self)
        }
    })
  }
  
}

extension PagingContentViewController: UIScrollViewDelegate {
  
  public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    let velocity = scrollView.panGestureRecognizer.velocityInView(view)
    if velocity.x < 0 {
      delegate?.pagingContentViewController(self, didBeginDraggingInDirection: .Forward)
    } else if velocity.x > 0 {
      delegate?.pagingContentViewController(self, didBeginDraggingInDirection: .Reverse)
    } else {
      delegate?.pagingContentViewController(self, didBeginDraggingInDirection: .None)
    }
  }
  
  public func scrollViewDidScroll(scrollView: UIScrollView) {
    let offset = CGFloat(scrollView.contentOffset.x / scrollView.bounds.width) - 1
    delegate?.pagingContentViewController(self, didChangeOffset: offset)
  }
  
}

extension PagingContentViewController: UIPageViewControllerDelegate {
  
  public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed {
      delegate?.pagingContentViewControllerDidCompleteTransition(self)
    }
  }
  
}
