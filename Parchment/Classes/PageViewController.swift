import UIKit

public final class PageViewController: UIViewController {
  public weak var dataSource: PageViewControllerDataSource?
  public weak var delegate: PageViewControllerDelegate?
  
  public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
    return false
  }
  
  public var selectedViewController: UIViewController? {
    return manager.selectedViewController
  }
  
  public private(set) lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.isPagingEnabled = true
    scrollView.scrollsToTop = false
    scrollView.bounces = true
    scrollView.alwaysBounceHorizontal = true
    scrollView.alwaysBounceVertical = false
    scrollView.translatesAutoresizingMaskIntoConstraints = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
  }()
  
  private let manager = PageViewManager()
  private let options: PagingOptions

  init(options: PagingOptions = PagingOptions()) {
    self.options = options
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    self.options = PagingOptions()
    super.init(coder: coder)
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    manager.delegate = self
    manager.dataSource = self
    view.addSubview(scrollView)
    view.constrainToEdges(scrollView)
    scrollView.delegate = self
    
    if #available(iOS 11.0, *) {
      scrollView.contentInsetAdjustmentBehavior = .never
    }
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    view.layoutIfNeeded()
    manager.viewWillAppear(animated: animated)
  }
  
  
  public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    coordinator.animate(alongsideTransition: { _ in
      self.manager.viewWillTransitionSize()
    })
  }
  
  // MARK: - Public Methods
  
  public func selectViewController(_ viewController: UIViewController, direction: PageViewDirection, animated: Bool = true) {
    manager.select(viewController: viewController, direction: direction, animated: animated)
  }
  
  public func selectNext(animated: Bool) {
    manager.selectNext(animated: animated)
  }

  public func selectPrevious(animated: Bool) {
    manager.selectPrevious(animated: animated)
  }
  
  public func removeAll() {
    manager.removeAll()
  }
}

extension PageViewController: UIScrollViewDelegate {
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    manager.willBeginDragging()
  }
  
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    manager.willEndDragging()
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let distance = view.frame.size.width
    var progress: CGFloat

    switch manager.state {
    case .first, .empty, .single:
      progress = scrollView.contentOffset.x / distance
    case .center, .last:
      progress = (scrollView.contentOffset.x - distance) / distance
    }
    
    manager.didScroll(progress: progress)
  }
}

extension PageViewController: PageViewManagerDataSource {
  func viewControllerAfter(_ viewController: UIViewController) -> UIViewController? {
    return dataSource?.pageViewController(self, viewControllerAfterViewController: viewController)
  }
  
  func viewControllerBefore(_ viewController: UIViewController) -> UIViewController? {
    return dataSource?.pageViewController(self, viewControllerBeforeViewController: viewController)
  }
}

extension PageViewController: PageViewManagerDelegate {
  func scrollForward() {
    switch manager.state {
    case .first:
      let contentOffset = CGPoint(x: view.bounds.width, y: 0)
      scrollView.setContentOffset(contentOffset, animated: true)
    case .center:
      let contentOffset = CGPoint(x: view.bounds.width * 2, y: 0)
      scrollView.setContentOffset(contentOffset, animated: true)
    case .single, .empty, .last:
      break
    }
  }
  
  func scrollReverse() {
    switch manager.state {
    case .last, .center:
      manager.willBeginDragging()
      scrollView.setContentOffset(.zero, animated: true)
    case .single, .empty, .first:
      break
    }
  }
  
  func layoutViews(for viewControllers: [UIViewController], keepContentOffset: Bool) {
    for (index, viewController) in viewControllers.enumerated() {
      viewController.view.frame = CGRect(
        x: CGFloat(index) * scrollView.bounds.width,
        y: 0,
        width: scrollView.bounds.width,
        height: scrollView.bounds.height)
    }
    
    // When updating the content offset we need to account for the
    // current content offset as well. This ensures that the selected
    // page is fully centered when swiping so fast that you get the
    // bounce effect in the scroll view.
    var diff: CGFloat = 0
    if keepContentOffset {
      if scrollView.contentOffset.x > view.bounds.width * 2 {
        diff = scrollView.contentOffset.x - view.bounds.width * 2
      } else if scrollView.contentOffset.x > view.bounds.width && scrollView.contentOffset.x < view.bounds.width * 2 {
        diff = scrollView.contentOffset.x - view.bounds.width
      } else if scrollView.contentOffset.x < view.bounds.width && scrollView.contentOffset.x < 0 {
        diff = scrollView.contentOffset.x
      }
    }
    
    // Need to set content size before updating content offset. If not
    // the views will be misplaced when overshooting.
    scrollView.contentSize = CGSize(
      width: CGFloat(manager.state.count) * view.bounds.width,
      height: view.bounds.height)
    
    switch manager.state {
    case .first, .single, .empty:
      scrollView.contentOffset = CGPoint(x: diff, y: 0)
    case .last, .center:
      scrollView.contentOffset = CGPoint(x: view.bounds.width + diff, y: 0)
    }
  }
  
  func addViewController(_ viewController: UIViewController) {
    viewController.willMove(toParent: self)
    addChild(viewController)
    scrollView.addSubview(viewController.view)
    viewController.didMove(toParent: self)
  }
  
  func removeViewController(_ viewController: UIViewController) {
    viewController.willMove(toParent: nil)
    viewController.removeFromParent()
    viewController.view.removeFromSuperview()
    viewController.didMove(toParent: nil)
  }
  
  func beginAppearanceTransition(isAppearing: Bool, viewController: UIViewController) {
    viewController.beginAppearanceTransition(isAppearing, animated: false)
  }
  
  func endAppearanceTransition(viewController: UIViewController) {
    viewController.endAppearanceTransition()
  }
  
  func willScroll(
    from selectedViewController: UIViewController,
    to destinationViewController: UIViewController) {
    delegate?.pageViewController(
      self,
      willStartScrollingFrom: selectedViewController,
      destinationViewController: destinationViewController)
  }
  
  func didFinishScrolling(
    from selectedViewController: UIViewController,
    to destinationViewController: UIViewController,
    transitionSuccessful: Bool) {
    delegate?.pageViewController(
      self,
      didFinishScrollingFrom: selectedViewController,
      destinationViewController: destinationViewController,
      transitionSuccessful: transitionSuccessful)
  }
  
  func isScrolling(
    from selectedViewController: UIViewController,
    to destinationViewController: UIViewController?,
    progress: CGFloat) {
    delegate?.pageViewController(
      self,
      isScrollingFrom: selectedViewController,
      destinationViewController: destinationViewController,
      progress: progress)
  }
}
