import UIKit

public class PagingViewController<T: PagingItem where T: Equatable>: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPageViewControllerDataSource {
  
  public let options: PagingOptions
  public weak var delegate: PagingViewControllerDelegate?
  public weak var dataSource: PagingViewControllerDataSource?
  
  private var stateMachine: PagingStateMachine<T>? {
    didSet {
      handleStateMachineUpdate(oldValue)
    }
  }
  
  private var dataStructure: PagingDataStructure<T> {
    didSet {
      handleDataStructureUpdate(oldValue)
    }
  }
  
  private lazy var defaultDelegate: PagingOptionsDelegate = {
    return PagingOptionsDelegate(options: self.options, collectionView: self.collectionView)
  }()
  
  
  public init(options: PagingOptions = DefaultPagingOptions()) {
    self.options = options
    self.dataStructure = PagingDataStructure(visibleItems: [])
    super.init(nibName: nil, bundle: nil)

    delegate = defaultDelegate
  }

  required public init?(coder: NSCoder) {
    self.options = DefaultPagingOptions()
    self.dataStructure = PagingDataStructure(visibleItems: [])
    super.init(coder: coder)
    
    delegate = defaultDelegate
  }
  
  public override func loadView() {
    view = PagingView(
      pagingContentView: pagingContentViewController.view,
      collectionView: collectionView,
      options: options)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    addViewController(pagingContentViewController)
    collectionView.registerClass(options.menuItemClass,
      forCellWithReuseIdentifier: PagingCell.reuseIdentifier)
  }
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    reloadData()
  }
  
  public func reloadData() {
    guard
      let delegate = delegate,
      let dataSource = dataSource,
      let initialPagingItem = dataSource.initialPagingItem() as? T else { return }
    
    stateMachine = PagingStateMachine(initialPagingItem: initialPagingItem)
    
    dataStructure = PagingDataStructure(visibleItems: visibleItems(initialPagingItem,
      width: collectionView.bounds.width,
      dataSource: dataSource,
      delegate: delegate))
    
    selectViewController(initialPagingItem,
                         direction: .None,
                         animated: false)
    
    selectCollectionViewCell(initialPagingItem,
                             scrollPosition: options.scrollPosition)
  }
  
  // MARK: Private
  
  private func handleEventUpdate(event: PagingEvent<T>) {
    switch event {
    case let .Select(pagingItem, direction):
      handleSelectEvent(pagingItem, direction: direction)
    case let .Reload(pagingItem, size):
      handleReloadEvent(pagingItem, size: size)
    default:
      break
    }
  }

  private func handleStateUpdate(state: PagingState<T>) {
    collectionViewLayout.state = state
    switch state {
    case let .Current(pagingItem):
      stateMachine?.fire(.Reload(
        pagingItem: pagingItem,
        size: collectionView.bounds.size))
      selectCollectionViewCell(pagingItem,
                               scrollPosition: options.scrollPosition,
                               animated: true)
    case .Next, .Previous:
      collectionViewLayout.invalidateLayout()
      selectCollectionViewCell(state.visualSelectionPagingItem, scrollPosition: .None)
    }
  }
  
  private func handleSelectEvent(pagingItem: T, direction: PagingDirection) {
    selectViewController(pagingItem, direction: direction)
  }
  
  private func handleReloadEvent(pagingItem: T, size: CGSize) {
    guard
      let delegate = delegate,
      let dataSource = dataSource else { return }
    
    dataStructure = PagingDataStructure(visibleItems: visibleItems(pagingItem,
      width: size.width,
      dataSource: dataSource,
      delegate: delegate))
  }
  
  private func handleStateMachineUpdate(oldValue: PagingStateMachine<T>?) {
    stateMachine?.stateObservers.append { [weak self] (stateMachine, oldState) in
      self?.handleStateUpdate(stateMachine.state)
    }
    
    stateMachine?.eventObservers.append { [weak self] (stateMachine, event) in
      self?.handleEventUpdate(event)
    }
  }
  
  private func handleDataStructureUpdate(oldValue: PagingDataStructure<T>) {
    guard
      let delegate = delegate,
      let dataSource = dataSource else { return }
    
    let itemsWidth = diffWidth(
      from: oldValue,
      to: dataStructure,
      dataSource: dataSource,
      delegate: delegate)
    
    let contentOffset: CGPoint = collectionView.contentOffset
    
    collectionViewLayout.dataStructure = dataStructure
    collectionView.reloadData()
    
    collectionView.contentOffset = CGPoint(
      x: contentOffset.x + itemsWidth,
      y: collectionView.contentOffset.y)
  }

  // MARK: Lazy Getters
  
  private lazy var collectionViewLayout: PagingCollectionViewLayout<T> = {
    return PagingCollectionViewLayout(options: self.options)
  }()
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.collectionViewLayout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.scrollEnabled = false
    return collectionView
  }()
  
  private func selectViewController(pagingItem: T, direction: PagingDirection, animated: Bool = true) {
    guard let dataSource = dataSource else { return }
    let viewController = dataSource.viewControllerForPagingItem(pagingItem)
    pagingContentViewController.setViewController(viewController,
                                                  direction: direction,
                                                  animated: animated)
  }
  
  private lazy var pagingContentViewController: PagingContentViewController = {
    let pagingContentViewController = PagingContentViewController()
    pagingContentViewController.delegate = self
    pagingContentViewController.pageViewController.dataSource = self
    return pagingContentViewController
  }()
  private func selectCollectionViewCell(pagingItem: T, scrollPosition: UICollectionViewScrollPosition, animated: Bool = false) {
    let indexPath = dataStructure.indexPathForPagingItem(pagingItem)
    collectionView.selectItemAtIndexPath(indexPath,
                                         animated: animated,
                                         scrollPosition: scrollPosition)
  }
  
  // MARK: UICollectionViewDelegateFlowLayout
  
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let pagingItem = dataStructure.pagingItemForIndexPath(indexPath)
    let width = delegate?.widthForPagingItem(pagingItem) ?? 0
    return CGSize(width: width, height: options.menuItemSize.height)
  }
  
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    guard let stateMachine = stateMachine else { return }
    
    let currentPagingItem = stateMachine.state.currentPagingItem
    let upcomingPagingItem = dataStructure.pagingItemForIndexPath(indexPath)
    let direction = dataStructure.directionForIndexPath(indexPath, currentPagingItem: currentPagingItem)
    
    stateMachine.fire(.Select(
      pagingItem: upcomingPagingItem,
      direction: direction))
  }
  
  public func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    if case .AlwaysCentered = options.selectedScrollPosition {
      let indexPath = NSIndexPath(forItem: 0, inSection: 0)
      let layoutAttributes = collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath)
      
      if let layoutAttributes = layoutAttributes {
        let left = collectionView.bounds.midX - layoutAttributes.bounds.midX
        return UIEdgeInsets(hortizontal: left)
      }
    }
    return UIEdgeInsets()
  }
  
  // MARK: UICollectionViewDataSource
  
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PagingCell.reuseIdentifier, forIndexPath: indexPath) as! PagingCell
    cell.setPagingItem(dataStructure.visibleItems[indexPath.item], theme: options.theme)
    return cell
  }
  
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataStructure.visibleItems.count
  }
  
  // MARK: UIPageViewControllerDataSource
  
  public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    guard
      let dataSource = dataSource,
      let state = stateMachine?.state.currentPagingItem,
      let pagingItem = dataSource.pagingItemBeforePagingItem(state) else { return nil }
    
    return dataSource.viewControllerForPagingItem(pagingItem)
  }
  
  public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    guard
      let dataSource = dataSource,
      let state = stateMachine?.state.currentPagingItem,
      let pagingItem = dataSource.pagingItemAfterPagingItem(state) else { return nil }
    
    return dataSource.viewControllerForPagingItem(pagingItem)
  }
  
}

extension PagingViewController: PagingContentViewControllerDelegate {
  
  // MARK: PagingContentViewControllerDelegate
  
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didBeginDraggingInDirection direction: PagingDirection) {
    guard
      let stateMachine = stateMachine,
      let dataSource = dataSource else { return }
    
    switch direction {
    case .Forward:
      stateMachine.fire(.DidBeginDragging(
        upcomingPagingItem: dataSource.pagingItemAfterPagingItem(stateMachine.state.currentPagingItem) as? T,
        direction: direction))
    case .Reverse:
      stateMachine.fire(.DidBeginDragging(
        upcomingPagingItem: dataSource.pagingItemBeforePagingItem(stateMachine.state.currentPagingItem) as? T,
        direction: direction))
    default:
      break
    }
  }
  
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didChangeOffset offset: CGFloat) {
    guard let stateMachine = stateMachine else { return }
    stateMachine.fire(.Update(offset: offset))
  }
  
  func pagingContentViewControllerDidCompleteTransition(pagingContentViewController: PagingContentViewController) {
    guard let stateMachine = stateMachine else { return }
    let pagingItem = stateMachine.state.upcomingPagingItem ?? stateMachine.state.currentPagingItem
    stateMachine.fire(.DidMove(pagingItem: pagingItem))
  }
  
}
