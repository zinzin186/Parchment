import UIKit

private let PagingCellReuseIdentifier = "PagingCellReuseIdentifier"

public class PagingViewController<T: PagingItem where T: Equatable>: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPageViewControllerDataSource {
  
  private let options: PagingOptions
  private var stateMachine: PagingStateMachine<T>?
  private var dataStructure: PagingDataStructure<T>?
  
  public weak var dataSource: PagingViewControllerDataSource? {
    didSet {
      handleDataSourceUpdate()
    }
  }
  
  public init(options: PagingOptions = DefaultPagingOptions()) {
    self.options = options
    super.init(nibName: nil, bundle: nil)
  }

  required public init?(coder: NSCoder) {
    self.options = DefaultPagingOptions()
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
    
    stateMachine?.stateObservers.append { [weak self] (stateMachine, oldState) in
      self?.handleStateUpdate(stateMachine.state)
    }
    
    stateMachine?.eventObservers.append { [weak self] (stateMachine, event) in
      self?.handleEventUpdate(event)
    }

    collectionView.registerClass(options.menuItemClass,
      forCellWithReuseIdentifier: PagingCellReuseIdentifier)
  }
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    guard let stateMachine = stateMachine else { return }
    
    reloadVisibleItems(stateMachine.state.currentPagingItem)
    
    guard let dataStructure = dataStructure else { return }
    
    let scrollPosition = options.selectedScrollPosition.collectionViewScrollPosition()
    let indexPath = dataStructure.indexPathForPagingItem(stateMachine.state.currentPagingItem)
    
    collectionView.selectItemAtIndexPath(indexPath,
      animated: false,
      scrollPosition: scrollPosition)
  }
  
  // MARK: Private
  
  private func handleDataSourceUpdate() {
    guard
      let dataSource = dataSource,
      let initialPagingItem = dataSource.initialPagingItem() as? T else { return }
    
    stateMachine = PagingStateMachine(initialPagingItem: initialPagingItem)
    
    dataStructure = PagingDataStructure(visibleItems: visibleItems(initialPagingItem,
      width: collectionView.bounds.width,
      dataSource: dataSource,
      options: options))
    
    reloadVisibleItems(initialPagingItem)
    
    let viewController = dataSource.viewControllerForPagingItem(initialPagingItem)
    pagingContentViewController.setViewController(viewController,
      direction: .None,
      animated: false)
  }
  
  private func handleEventUpdate(event: PagingEvent<T>) {
    guard let dataSource = dataSource else { return }
    switch event {
    case let .Select(pagingItem, direction):
      let viewController = dataSource.viewControllerForPagingItem(pagingItem)
      pagingContentViewController.setViewController(viewController,
        direction: direction,
        animated: true)
    default:
      break
    }
  }

  private func handleStateUpdate(state: PagingState<T>) {
    
    collectionViewLayout.state = state
    
    switch state {
    case let .Current(pagingItem):
      
      reloadVisibleItems(pagingItem)
      
      guard let dataStructure = dataStructure else { return }
      
      let scrollPosition = options.selectedScrollPosition.collectionViewScrollPosition()
      let indexPath = dataStructure.indexPathForPagingItem(pagingItem)
      
      collectionView.selectItemAtIndexPath(indexPath,
        animated: true,
        scrollPosition: scrollPosition)

    case .Next, .Previous:
      guard let dataStructure = dataStructure else { return }
      let indexPath = dataStructure.indexPathForPagingItem(state.visualSelectionPagingItem)
      collectionViewLayout.invalidateLayout()
      collectionView.selectItemAtIndexPath(indexPath,
        animated: false,
        scrollPosition: .None)
    }
  }
  
  private func reloadVisibleItems(pagingItem: T) {
    
    guard
      let dataStructure = dataStructure,
      let dataSource = dataSource else { return }
    
    let to = PagingDataStructure(visibleItems: visibleItems(pagingItem,
      width: collectionView.bounds.width,
      dataSource: dataSource,
      options: options))
    
    let itemsWidth = diffWidth(
      from: dataStructure,
      to: to,
      dataSource: dataSource,
      options: options)
    
    let contentOffset: CGPoint = collectionView.contentOffset
    
    self.dataStructure = to
    collectionViewLayout.dataStructure = to
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
  
  
  private lazy var pagingContentViewController: PagingContentViewController = {
    let pagingContentViewController = PagingContentViewController()
    pagingContentViewController.delegate = self
    pagingContentViewController.pageViewController.dataSource = self
    return pagingContentViewController
  }()
  

  // MARK: UICollectionViewDelegateFlowLayout
  
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    switch options.menuItemSize {
    case let .SizeToFit(minWidth, height):
      let width = max(minWidth, collectionView.bounds.width / CGFloat(collectionView.numberOfItemsInSection(0)))
      return CGSize(width: width, height: height)
    case let .Fixed(width, height):
      return CGSize(width: width, height: height)
    }
  }
  
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    guard
      let stateMachine = stateMachine,
      let dataStructure = dataStructure else { return }
    
    let upcomingPagingItem = dataStructure.pagingItemForIndexPath(indexPath)
    let direction = dataStructure.directionForIndexPath(indexPath,
      currentPagingItem: stateMachine.state.currentPagingItem)
    stateMachine.fire(.Select(pagingItem: upcomingPagingItem, direction: direction))
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
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PagingCellReuseIdentifier,
      forIndexPath: indexPath) as! PagingCell
    if let dataStructure = dataStructure {
      cell.setPagingItem(dataStructure.visibleItems[indexPath.item], theme: options.theme)
    }
    return cell
  }
  
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let dataStructure = dataStructure else { return 0 }
    return dataStructure.visibleItems.count
  }
  
  // MARK: UIPageViewControllerDataSource
  
  public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    guard
      let stateMachine = stateMachine,
      let dataSource = dataSource,
      let pagingItem = dataSource.pagingItemBeforePagingItem(stateMachine.state.currentPagingItem) else { return nil }
    
    return dataSource.viewControllerForPagingItem(pagingItem)
  }
  
  public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    guard
      let stateMachine = stateMachine,
      let dataSource = dataSource,
      let pagingItem = dataSource.pagingItemAfterPagingItem(stateMachine.state.currentPagingItem) else { return nil }
    
    return dataSource.viewControllerForPagingItem(pagingItem)
  }
  
}

extension PagingViewController: PagingContentViewControllerDelegate {
  
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

