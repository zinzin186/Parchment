import UIKit

public class PagingViewController<T: PagingItem where T: Equatable>: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPageViewControllerDataSource, PagingItemsPresentable {
  
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
  
  public lazy var collectionViewLayout: PagingCollectionViewLayout<T> = {
    return PagingCollectionViewLayout(options: self.options, dataStructure: self.dataStructure)
  }()
  
  public lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
    collectionView.backgroundColor = .whiteColor()
    collectionView.scrollEnabled = false
    return collectionView
  }()
  
  public let pagingContentViewController: PagingContentViewController = {
    return PagingContentViewController()
  }()
  
  public init(options: PagingOptions = DefaultPagingOptions()) {
    self.options = options
    self.dataStructure = PagingDataStructure(visibleItems: [])
    super.init(nibName: nil, bundle: nil)
  }

  required public init?(coder: NSCoder) {
    self.options = DefaultPagingOptions()
    self.dataStructure = PagingDataStructure(visibleItems: [])
    super.init(coder: coder)
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
    
    collectionView.delegate = self
    collectionView.dataSource = self
    pagingContentViewController.delegate = self
    pagingContentViewController.pageViewController.dataSource = self
    
    collectionView.registerClass(options.menuItemClass,
      forCellWithReuseIdentifier: PagingCell.reuseIdentifier)
  }
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    reloadData()
  }
  
  public func reloadData() {
    guard
      let dataSource = dataSource,
      let initialPagingItem = dataSource.initialPagingItem() as? T else { return }
    
    stateMachine = PagingStateMachine(initialPagingItem: initialPagingItem)
    
    let items = visibleItems(initialPagingItem, width: collectionView.bounds.width)
    dataStructure = PagingDataStructure(visibleItems: items)
    
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
    let items = visibleItems(pagingItem, width: size.width)
    dataStructure = PagingDataStructure(visibleItems: items)
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
  
    let itemsWidth = diffWidth(from: oldValue, to: dataStructure)
    let contentOffset: CGPoint = collectionView.contentOffset
    
    collectionViewLayout.dataStructure = dataStructure
    collectionView.reloadData()
    
    collectionView.contentOffset = CGPoint(
      x: contentOffset.x + itemsWidth,
      y: collectionView.contentOffset.y)
  }
  
  private func selectViewController(pagingItem: T, direction: PagingDirection, animated: Bool = true) {
    guard let dataSource = dataSource else { return }
    let viewController = dataSource.viewControllerForPagingItem(pagingItem)
    pagingContentViewController.setViewController(viewController,
                                                  direction: direction,
                                                  animated: animated)
  }
  
  private func selectCollectionViewCell(pagingItem: T, scrollPosition: UICollectionViewScrollPosition, animated: Bool = false) {
    let indexPath = dataStructure.indexPathForPagingItem(pagingItem)
    collectionView.selectItemAtIndexPath(indexPath,
                                         animated: animated,
                                         scrollPosition: scrollPosition)
  }
  
  // MARK: UICollectionViewDelegateFlowLayout
  
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSize(
      width: widthForPagingItem(dataStructure.pagingItemForIndexPath(indexPath)),
      height: options.menuItemSize.height)
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
  
  // MARK: PagingItemsPresentable
  
  func widthForPagingItem<U: PagingItem>(pagingItem: U) -> CGFloat {
    guard let pagingItem = pagingItem as? T else { return 0 }
    switch options.menuItemSize {
    case let .SizeToFit(minWidth, _):
      return max(minWidth, collectionView.bounds.width / CGFloat(collectionView.numberOfItemsInSection(0)))
    case let .Fixed(width, _):
      return width
    case .Dynamic:
      return delegate?.pagingViewController(self, widthForPagingItem: pagingItem) ?? 0
    }
  }
  
  func pagingItemAfterPagingItem<T : PagingItem>(pagingItem: T) -> T? {
    return dataSource?.pagingItemAfterPagingItem(pagingItem) as? T
  }
  
  func pagingItemBeforePagingItem<T : PagingItem>(pagingItem: T) -> T? {
    return dataSource?.pagingItemBeforePagingItem(pagingItem) as? T
  }
  
}

extension PagingViewController: PagingContentViewControllerDelegate {
  
  // MARK: PagingContentViewControllerDelegate
  
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didBeginDraggingInDirection direction: PagingDirection) {
    guard let stateMachine = stateMachine else { return }
    
    switch direction {
    case .Forward:
      stateMachine.fire(.DidBeginDragging(
        upcomingPagingItem: pagingItemAfterPagingItem(stateMachine.state.currentPagingItem),
        direction: direction))
    case .Reverse:
      stateMachine.fire(.DidBeginDragging(
        upcomingPagingItem: pagingItemBeforePagingItem(stateMachine.state.currentPagingItem),
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
