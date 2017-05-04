import UIKit

open class PagingViewController<T: PagingItem>:
  UIViewController,
  UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout,
  EMPageViewControllerDataSource,
  EMPageViewControllerDelegate,
  PagingItemsPresentable,
  PagingStateMachineDelegate where T: Equatable {
  
  open let options: PagingOptions
  open weak var delegate: PagingViewControllerDelegate?
  open weak var dataSource: PagingViewControllerDataSource?
  fileprivate var dataStructure: PagingDataStructure<T>
  
  internal var stateMachine: PagingStateMachine<T>? {
    didSet {
      handleStateMachineUpdate()
    }
  }
  
  open lazy var collectionViewLayout: PagingCollectionViewLayout<T> = {
    return PagingCollectionViewLayout(options: self.options, dataStructure: self.dataStructure)
  }()
  
  open lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
    collectionView.backgroundColor = .white
    collectionView.isScrollEnabled = false
    return collectionView
  }()
  
  open let pageViewController: EMPageViewController = {
    return EMPageViewController(navigationOrientation: .horizontal)
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
  
  open override func loadView() {
    view = PagingView(
      pageView: pageViewController.view,
      collectionView: collectionView,
      options: options)
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    addChildViewController(pageViewController)
    pageViewController.didMove(toParentViewController: self)
    
    collectionView.delegate = self
    collectionView.dataSource = self
    pageViewController.delegate = self
    pageViewController.dataSource = self
    
    collectionView.registerReusableCell(options.menuItemClass)
    
    setupGestureRecognizers()
    
    if let state = stateMachine?.state {
      selectViewController(
        state.currentPagingItem,
        direction: .none,
        animated: false)
    }
  }
  
  open func selectPagingItem(_ pagingItem: T, animated: Bool = false) {
    
    if let stateMachine = stateMachine {
      if let indexPath = dataStructure.indexPathForPagingItem(pagingItem) {
        let direction = dataStructure.directionForIndexPath(indexPath, currentPagingItem: pagingItem)
        stateMachine.fire(.select(
          pagingItem: pagingItem,
          direction: direction,
          animated: animated))
      }
    } else {
      let state: PagingState = .selected(pagingItem: pagingItem)
      stateMachine = PagingStateMachine(initialState: state)
      collectionViewLayout.state = state
      
      if isViewLoaded {
        selectViewController(
          state.currentPagingItem,
          direction: .none,
          animated: false)
        
        if view.window != nil {
          generateItems(around: state.currentPagingItem)
          collectionView.selectItem(
            at: dataStructure.indexPathForPagingItem(state.currentPagingItem),
            animated: false,
            scrollPosition: options.scrollPosition)
        }
      }
    }
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let state = stateMachine?.state else { return }
    
    view.layoutIfNeeded()
    generateItems(around: state.currentPagingItem)
    collectionView.selectItem(
      at: dataStructure.indexPathForPagingItem(state.currentPagingItem),
      animated: false,
      scrollPosition: options.scrollPosition)
  }
  
  open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    guard let stateMachine = stateMachine else { return }
    coordinator.animate(alongsideTransition: { context in
      
      stateMachine.fire(.cancelScrolling)
      
      self.reloadItems(around: stateMachine.state.currentPagingItem)
      
      self.collectionView.selectItem(
        at: self.dataStructure.indexPathForPagingItem(stateMachine.state.currentPagingItem),
        animated: false,
        scrollPosition: self.options.scrollPosition)
      
      self.collectionViewLayout.invalidateLayout()
      
      }, completion: nil)
  }
  
  // MARK: Private
  
  fileprivate func setupGestureRecognizers() {
    let recognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer))
    recognizerLeft.direction = .left
    
    let recognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer))
    recognizerRight.direction = .right
    
    collectionView.addGestureRecognizer(recognizerLeft)
    collectionView.addGestureRecognizer(recognizerRight)
  }
  
  fileprivate dynamic func handleSwipeGestureRecognizer(_ recognizer: UISwipeGestureRecognizer) {
    guard let stateMachine = stateMachine else { return }
    
    let currentPagingItem = stateMachine.state.currentPagingItem
    var upcomingPagingItem: T? = nil
    
    if recognizer.direction.contains(.left) {
      upcomingPagingItem = pagingItemAfterPagingItem(currentPagingItem)
    } else if recognizer.direction.contains(.right) {
      upcomingPagingItem = pagingItemBeforePagingItem(currentPagingItem)
    }
    
    if let item = upcomingPagingItem {
      selectPagingItem(item, animated: true)
    }
  }
  
  fileprivate func handleStateUpdate(_ state: PagingState<T>, event: PagingEvent<T>?) {
    collectionViewLayout.state = state
    switch state {
    case let .selected(pagingItem):

      reloadItems(around: pagingItem)
      collectionView.selectItem(
        at: dataStructure.indexPathForPagingItem(pagingItem),
        animated: options.menuTransition == .animateAfter,
        scrollPosition: options.scrollPosition)

    case .scrolling:
      
      if options.menuTransition == .scrollAlongside {
        if state.distance != 0 {
          if dataStructure.totalWidth + options.menuInsets.horizontal >= collectionView.bounds.width {

            let contentOffset = CGPoint(
              x: state.contentOffset.x + (state.distance * fabs(state.progress)),
              y: state.contentOffset.y)
            
            collectionView.setContentOffset(contentOffset, animated: false)
          }
        }
      }
      
      collectionViewLayout.invalidateLayout()
      collectionView.selectItem(
        at: dataStructure.indexPathForPagingItem(state.visuallySelectedPagingItem),
        animated: false,
        scrollPosition: UICollectionViewScrollPosition())
    }
  }
  
  fileprivate func handleStateMachineUpdate() {
    stateMachine?.didSelectPagingItem = { [weak self] pagingItem, direction, animated in
      self?.selectViewController(pagingItem, direction: direction, animated: animated)
    }
    
    stateMachine?.didChangeState = { [weak self] state, event in
      self?.handleStateUpdate(state, event: event)
    }
    
    stateMachine?.delegate = self
  }
  
  fileprivate func generateItems(around pagingItem: T) {
    let toItems = visibleItems(pagingItem, width: collectionView.bounds.width * 1.5)
    let totalWidth = toItems.reduce(0) { widthForPagingItem($0.1) + $0.0 }
    
    dataStructure = PagingDataStructure(visibleItems: toItems, totalWidth: totalWidth)
    collectionViewLayout.dataStructure = dataStructure
    collectionView.reloadData()
  }
  
  fileprivate func reloadItems(around pagingItem: T) {
    let oldContentOffset: CGPoint = collectionView.contentOffset
    let fromItems = dataStructure.visibleItems
    
    generateItems(around: pagingItem)
    
    let offset = diffWidth(
      from: fromItems,
      to: dataStructure.visibleItems,
      itemSpacing: options.menuItemSpacing)
    
    collectionView.contentOffset = CGPoint(
      x: oldContentOffset.x + offset,
      y: oldContentOffset.y)
    collectionView.layoutIfNeeded()
  }
  
  fileprivate func selectViewController(_ pagingItem: T, direction: PagingDirection, animated: Bool = true) {
    guard let dataSource = dataSource else { return }
    pageViewController.selectViewController(
      dataSource.pagingViewController(self, viewControllerForPagingItem: pagingItem),
      direction: direction.pageViewControllerNavigationDirection,
      animated: animated,
      completion: nil)
  }
  
  fileprivate func distance(from: UICollectionViewCell, to: UICollectionViewCell) -> CGFloat {
    switch (options.selectedScrollPosition) {
    case .left:
      return to.frame.origin.x - collectionView.contentOffset.x
    case .right:
      let currentPosition = to.frame.origin.x + to.frame.width
      let width = collectionView.contentOffset.x + collectionView.bounds.width
      return currentPosition - width
    case .preferCentered:
      let distanceToCenter = collectionView.bounds.midX - from.frame.midX
      let distanceBetweenCells = to.frame.midX - from.frame.midX
      return distanceBetweenCells - distanceToCenter
    }
  }

  // MARK: UICollectionViewDelegateFlowLayout
  
  open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if case .sizeToFit = options.menuItemSize {
      let inset = options.menuInsets.left + options.menuInsets.right
      if dataStructure.totalWidth + inset < collectionView.bounds.width {
        return CGSize(
          width: (collectionView.bounds.width - inset) / CGFloat(dataStructure.visibleItems.count),
          height: options.menuItemSize.height)
      }
    }
    return CGSize(
      width: widthForPagingItem(dataStructure.pagingItemForIndexPath(indexPath)),
      height: options.menuItemSize.height)
  }
    
  open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    switch options.menuHorizontalAlignment {
    case .center:
      if case .sizeToFit = options.menuItemSize {
        return options.menuInsets
      }
      var itemsWidth: CGFloat = 0.0
      for index in dataStructure.visibleItems.indices {
        let indexPath = IndexPath(item: index, section: section)
        itemsWidth += widthForPagingItem(dataStructure.pagingItemForIndexPath(indexPath))
      }
      let itemSpacing = options.menuItemSpacing * CGFloat(dataStructure.visibleItems.count - 1)
      let padding = collectionView.bounds.width - itemsWidth - itemSpacing
      let horizontalInset = max(0, padding) / 2
      return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    case .default:
      return options.menuInsets
    }
  }
  
  open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let stateMachine = stateMachine else { return }
    
    let currentPagingItem = stateMachine.state.currentPagingItem
    let selectedPagingItem = dataStructure.pagingItemForIndexPath(indexPath)
    let direction = dataStructure.directionForIndexPath(indexPath, currentPagingItem: currentPagingItem)

    stateMachine.fire(.select(
      pagingItem: selectedPagingItem,
      direction: direction,
      animated: true))
  }
  
  // MARK: UICollectionViewDataSource
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(indexPath: indexPath, cellType: options.menuItemClass)
    let pagingItem = dataStructure.visibleItems[indexPath.item]
    let selected = stateMachine?.state.currentPagingItem == pagingItem
    cell.setPagingItem(pagingItem, selected: selected, theme: options.theme)
    return cell
  }
  
  open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataStructure.visibleItems.count
  }
  
  // MARK: EMPageViewControllerDataSource
  
  open func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    guard
      let dataSource = dataSource,
      let state = stateMachine?.state.currentPagingItem,
      let pagingItem = dataSource.pagingViewController(self, pagingItemBeforePagingItem: state) else { return nil }
    
    return dataSource.pagingViewController(self, viewControllerForPagingItem: pagingItem)
  }
  
  open func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    guard
      let dataSource = dataSource,
      let state = stateMachine?.state.currentPagingItem,
      let pagingItem = dataSource.pagingViewController(self, pagingItemAfterPagingItem: state) else { return nil }
    
    return dataSource.pagingViewController(self, viewControllerForPagingItem: pagingItem)
  }
  
  // MARK: PagingItemsPresentable
  
  func widthForPagingItem<U: PagingItem>(_ pagingItem: U) -> CGFloat {
    guard let pagingItem = pagingItem as? T else { return 0 }
    
    if let delegate = delegate {
      return delegate.pagingViewController(self, widthForPagingItem: pagingItem)
    }
    
    switch options.menuItemSize {
    case let .sizeToFit(minWidth, _):
      return minWidth
    case let .fixed(width, _):
      return width
    }
  }
  
  func pagingItemBeforePagingItem<U: PagingItem>(_ pagingItem: U) -> U? {
    return dataSource?.pagingViewController(self,
      pagingItemBeforePagingItem: pagingItem as! T) as? U
  }
  
  func pagingItemAfterPagingItem<U: PagingItem>(_ pagingItem: U) -> U? {
    return dataSource?.pagingViewController(self,
      pagingItemAfterPagingItem: pagingItem as! T) as? U
  }
  
  // MARK: EMPageViewControllerDelegate

  open func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {
    stateMachine?.fire(.scroll(progress: progress))
  }
  
  open func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
    if transitionSuccessful {
      stateMachine?.fire(.finishScrolling)
    }
  }
  
  // MARK: PagingStateMachineDelegate
  
  func pagingStateMachine<U>(
    _ pagingStateMachine: PagingStateMachine<U>,
    transitionFrom pagingItem: U,
    to upcomingPagingItem: U?) -> PagingTransition {
    
    guard
      let pagingItem = pagingItem as? T,
      let currentIndexPath = dataStructure.indexPathForPagingItem(pagingItem),
      let upcomingPagingItem = upcomingPagingItem as? T,
      let upcomingIndexPath = dataStructure.indexPathForPagingItem(upcomingPagingItem) else {
        
        return PagingTransition(
          contentOffset: collectionView.contentOffset,
          distance: 0)
    }
    
    let currentCell = collectionView(collectionView, cellForItemAt: currentIndexPath)
    let upcomingCell = collectionView(collectionView, cellForItemAt: upcomingIndexPath)
    var distance = self.distance(from: currentCell, to: upcomingCell)
   
    if collectionView.near(edge: .left, clearance: -distance) && distance < 0 {
      distance = -(collectionView.contentOffset.x + collectionView.contentInset.left)
    } else if collectionView.near(edge: .right, clearance: distance) && distance > 0 {
      distance = collectionView.contentSize.width - (collectionView.contentOffset.x + collectionView.bounds.width)
    }
    
    return PagingTransition(
      contentOffset: collectionView.contentOffset,
      distance: distance)
  }
  
  func pagingStateMachine<U>(
    _ pagingStateMachine: PagingStateMachine<U>,
    pagingItemBeforePagingItem pagingItem: U) -> U? {
    guard let pagingItem = pagingItem as? T else { return nil }
    return pagingItemBeforePagingItem(pagingItem) as? U
  }
  
  func pagingStateMachine<U>(
    _ pagingStateMachine: PagingStateMachine<U>,
    pagingItemAfterPagingItem pagingItem: U) -> U? {
    guard let pagingItem = pagingItem as? T else { return nil }
    return pagingItemAfterPagingItem(pagingItem) as? U
  }
  
}
