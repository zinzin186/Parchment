import UIKit

public class PagingViewController<T: PagingItem where T: Equatable>:
  UIViewController,
  UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout,
  EMPageViewControllerDataSource,
  EMPageViewControllerDelegate,
  PagingItemsPresentable,
  PagingStateMachineDelegate {
  
  public let options: PagingOptions
  public weak var delegate: PagingViewControllerDelegate?
  public weak var dataSource: PagingViewControllerDataSource?
  private var dataStructure: PagingDataStructure<T>
  
  private var stateMachine: PagingStateMachine<T>? {
    didSet {
      handleStateMachineUpdate()
    }
  }
  
  public lazy var collectionViewLayout: PagingCollectionViewLayout<T> = {
    return PagingCollectionViewLayout(options: self.options, dataStructure: self.dataStructure)
  }()
  
  public lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
    collectionView.backgroundColor = .whiteColor()
    collectionView.scrollEnabled = false
    return collectionView
  }()
  
  public let pageViewController: EMPageViewController = {
    return EMPageViewController(navigationOrientation: .Horizontal)
  }()
  
  public init(options: PagingOptions = DefaultPagingOptions()) {
    self.options = options
    self.dataStructure = PagingDataStructure(visibleItems: [], totalWidth: 0)
    super.init(nibName: nil, bundle: nil)
  }

  required public init?(coder: NSCoder) {
    self.options = DefaultPagingOptions()
    self.dataStructure = PagingDataStructure(visibleItems: [], totalWidth: 0)
    super.init(coder: coder)
  }
  
  public override func loadView() {
    view = PagingView(
      pageView: pageViewController.view,
      collectionView: collectionView,
      options: options)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    addChildViewController(pageViewController)
    pageViewController.didMoveToParentViewController(self)
    
    collectionView.delegate = self
    collectionView.dataSource = self
    pageViewController.delegate = self
    pageViewController.dataSource = self
    
    collectionView.registerReusableCell(options.menuItemClass)
    
    setupGestureRecognizers()
  }
  
  public func selectPagingItem(pagingItem: T, animated: Bool = false) {
    
    if let stateMachine = stateMachine {
      if let indexPath = dataStructure.indexPathForPagingItem(pagingItem) {
        let direction = dataStructure.directionForIndexPath(indexPath, currentPagingItem: pagingItem)
        stateMachine.fire(.Select(
          pagingItem: pagingItem,
          direction: direction,
          animated: animated))
      }
    } else {
      
      let state: PagingState = .Selected(pagingItem: pagingItem)
      stateMachine = PagingStateMachine(initialState: state)
      collectionViewLayout.state = state
      
      updateContentOffset(pagingItem)
      
      selectCollectionViewCell(
        pagingItem,
        scrollPosition: options.scrollPosition,
        animated: false)
      
      selectViewController(
        pagingItem,
        direction: .None,
        animated: false)
    }
  }
  
  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    guard let stateMachine = stateMachine else { return }
    coordinator.animateAlongsideTransition({ context in
      self.collectionView.selectItemAtIndexPath(
        self.dataStructure.indexPathForPagingItem(stateMachine.state.currentPagingItem),
        animated: false,
        scrollPosition: self.options.scrollPosition)
      self.collectionViewLayout.invalidateLayout()
      }, completion: nil)
  }
  
  // MARK: Private
  
  private func setupGestureRecognizers() {
    let recognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer))
    recognizerLeft.direction = .Left
    
    let recognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer))
    recognizerRight.direction = .Right
    
    collectionView.addGestureRecognizer(recognizerLeft)
    collectionView.addGestureRecognizer(recognizerRight)
  }
  
  private dynamic func handleSwipeGestureRecognizer(recognizer: UISwipeGestureRecognizer) {
    guard let stateMachine = stateMachine else { return }
    
    let currentPagingItem = stateMachine.state.currentPagingItem
    var upcomingPagingItem: T? = nil
    
    if recognizer.direction.contains(.Left) {
      upcomingPagingItem = pagingItemAfterPagingItem(currentPagingItem)
    } else if recognizer.direction.contains(.Right) {
      upcomingPagingItem = pagingItemBeforePagingItem(currentPagingItem)
    }
    
    if let item = upcomingPagingItem {
      selectPagingItem(item, animated: true)
    }
  }
  
  private func handleStateUpdate(state: PagingState<T>, event: PagingEvent<T>?) {
    collectionViewLayout.state = state
    switch state {
    case let .Selected(pagingItem):
      updateContentOffset(pagingItem)
      selectCollectionViewCell(
        pagingItem,
        scrollPosition: options.scrollPosition,
        animated: event?.animated ?? true)
    case .Scrolling:
      collectionViewLayout.invalidateLayout()
      selectCollectionViewCell(
        state.visuallySelectedPagingItem,
        scrollPosition: .None,
        animated: false)
    }
  }
  
  private func handleStateMachineUpdate() {
    stateMachine?.didSelectPagingItem = { [weak self] pagingItem, direction, animated in
      self?.selectViewController(pagingItem, direction: direction, animated: animated)
    }
    
    stateMachine?.didChangeState = { [weak self] state, event in
      self?.handleStateUpdate(state, event: event)
    }
    
    stateMachine?.delegate = self
  }
  
  private func updateContentOffset(pagingItem: T) {
    let oldContentOffset: CGPoint = collectionView.contentOffset
    let fromItems = dataStructure.visibleItems
    let toItems = visibleItems(pagingItem, width: collectionView.bounds.width)
    let totalWidth = toItems.reduce(0) { widthForPagingItem($0.1) + $0.0 }
    
    dataStructure = PagingDataStructure(visibleItems: toItems, totalWidth: totalWidth)
    collectionViewLayout.dataStructure = dataStructure
    collectionView.reloadData()
    
    let offset = diffWidth(
      from: fromItems,
      to: toItems,
      itemSpacing: options.menuItemSpacing)
    
    collectionView.contentOffset = CGPoint(
      x: oldContentOffset.x + offset,
      y: oldContentOffset.y)
  }
  
  private func selectViewController(pagingItem: T, direction: PagingDirection, animated: Bool = true) {
    guard let dataSource = dataSource else { return }
    pageViewController.selectViewController(
      dataSource.pagingViewController(self, viewControllerForPagingItem: pagingItem),
      direction: direction.pageViewControllerNavigationDirection,
      animated: animated,
      completion: nil)
  }
  
  private func selectCollectionViewCell(pagingItem: T, scrollPosition: UICollectionViewScrollPosition, animated: Bool) {
    collectionView.selectItemAtIndexPath(
      dataStructure.indexPathForPagingItem(pagingItem),
      animated: animated,
      scrollPosition: scrollPosition)
  }
  
  // MARK: UICollectionViewDelegateFlowLayout
  
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if case .SizeToFit = options.menuItemSize {
      if dataStructure.totalWidth < collectionView.bounds.width {
        return CGSize(
          width: collectionView.bounds.width / CGFloat(dataStructure.visibleItems.count),
          height: options.menuItemSize.height)
      }
    }
    return CGSize(
      width: widthForPagingItem(dataStructure.pagingItemForIndexPath(indexPath)),
      height: options.menuItemSize.height)
  }
  
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    guard let stateMachine = stateMachine else { return }
    
    let currentPagingItem = stateMachine.state.currentPagingItem
    let selectedPagingItem = dataStructure.pagingItemForIndexPath(indexPath)
    let direction = dataStructure.directionForIndexPath(indexPath, currentPagingItem: currentPagingItem)

    stateMachine.fire(.Select(
      pagingItem: selectedPagingItem,
      direction: direction,
      animated: true))
  }
  
  // MARK: UICollectionViewDataSource
  
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(indexPath: indexPath, cellType: options.menuItemClass)
    cell.setPagingItem(dataStructure.visibleItems[indexPath.item], theme: options.theme)
    return cell
  }
  
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataStructure.visibleItems.count
  }
  
  // MARK: EMPageViewControllerDataSource
  
  public func em_pageViewController(pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    guard
      let dataSource = dataSource,
      let state = stateMachine?.state.currentPagingItem,
      let pagingItem = dataSource.pagingViewController(self, pagingItemBeforePagingItem: state) else { return nil }
    
    return dataSource.pagingViewController(self, viewControllerForPagingItem: pagingItem)
  }
  
  public func em_pageViewController(pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    guard
      let dataSource = dataSource,
      let state = stateMachine?.state.currentPagingItem,
      let pagingItem = dataSource.pagingViewController(self, pagingItemAfterPagingItem: state) else { return nil }
    
    return dataSource.pagingViewController(self, viewControllerForPagingItem: pagingItem)
  }
  
  // MARK: PagingItemsPresentable
  
  func widthForPagingItem<U: PagingItem>(pagingItem: U) -> CGFloat {
    guard let pagingItem = pagingItem as? T else { return 0 }
    
    if let delegate = delegate {
      return delegate.pagingViewController(self, widthForPagingItem: pagingItem) ?? 0
    }
    
    switch options.menuItemSize {
    case let .SizeToFit(minWidth, _):
      return minWidth
    case let .Fixed(width, _):
      return width
    }
  }
  
  func pagingItemBeforePagingItem<U: PagingItem>(pagingItem: U) -> U? {
    return dataSource?.pagingViewController(self,
      pagingItemBeforePagingItem: pagingItem as! T) as? U
  }
  
  func pagingItemAfterPagingItem<U: PagingItem>(pagingItem: U) -> U? {
    return dataSource?.pagingViewController(self,
      pagingItemAfterPagingItem: pagingItem as! T) as? U
  }
  
  // MARK: EMPageViewControllerDelegate

  public func em_pageViewController(pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {
    stateMachine?.fire(.Scroll(offset: progress))
  }
  
  public func em_pageViewController(pageViewController: EMPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
    if transitionSuccessful {
      stateMachine?.fire(.FinishScrolling)
    }
  }
  
  // MARK: PagingStateMachineDelegate
  
  func pagingStateMachine<U>(
    pagingStateMachine: PagingStateMachine<U>,
    pagingItemBeforePagingItem pagingItem: U) -> U? {
    guard let pagingItem = pagingItem as? T else { return nil }
    return pagingItemBeforePagingItem(pagingItem) as? U
  }
  
  func pagingStateMachine<U>(
    pagingStateMachine: PagingStateMachine<U>,
    pagingItemAfterPagingItem pagingItem: U) -> U? {
    guard let pagingItem = pagingItem as? T else { return nil }
    return pagingItemAfterPagingItem(pagingItem) as? U
  }
  
}
