import UIKit

public class PagingViewController<T: PagingItem where T: Equatable>: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EMPageViewControllerDataSource, EMPageViewControllerDelegate, PagingItemsPresentable, PagingStateMachineDelegate {
  
  public let options: PagingOptions
  public weak var delegate: PagingViewControllerDelegate?
  public weak var dataSource: PagingViewControllerDataSource?
  
  private var stateMachine: PagingStateMachine<T>? {
    didSet {
      handleStateMachineUpdate()
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
  
  public let pageViewController: EMPageViewController = {
    return EMPageViewController(navigationOrientation: .Horizontal)
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
      pagingContentView: pageViewController.view,
      collectionView: collectionView,
      options: options)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    addViewController(pageViewController)
    
    collectionView.delegate = self
    collectionView.dataSource = self
    pageViewController.delegate = self
    pageViewController.dataSource = self
    
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
    
    let initialState: PagingState = .Selected(pagingItem: initialPagingItem)
    stateMachine = PagingStateMachine(initialState: initialState)
    
    selectViewController(initialPagingItem,
                         direction: .None,
                         animated: false)
    
    selectCollectionViewCell(initialPagingItem,
      scrollPosition: options.scrollPosition)
    
    reloadForPagingItem(initialPagingItem, size: collectionView.bounds.size)
    handleStateUpdate(initialState)
  }
  
  // MARK: Private
  
  private func reloadForPagingItem(pagingItem: T, size: CGSize) {
    let items = visibleItems(pagingItem, width: size.width)
    dataStructure = PagingDataStructure(visibleItems: items)
  }
  
  private func handleStateUpdate(state: PagingState<T>) {
    collectionViewLayout.state = state
    switch state {
    case .Selected:
      reloadForPagingItem(state.currentPagingItem,
                          size: collectionView.bounds.size)
      selectCollectionViewCell(state.currentPagingItem,
                               scrollPosition: options.scrollPosition,
                               animated: true)
    case .Scrolling:
      collectionViewLayout.invalidateLayout()
      selectCollectionViewCell(state.visuallySelectedPagingItem,
                               scrollPosition: .None)
    }
  }
  
  private func handleStateMachineUpdate() {
    stateMachine?.didSelectPagingItem = { [weak self] pagingItem, direction in
      self?.selectViewController(pagingItem, direction: direction)
    }
    
    stateMachine?.didChangeState = { [weak self] state in
      self?.handleStateUpdate(state)
    }
    
    stateMachine?.delegate = self
  }
  
  private func handleDataStructureUpdate(oldValue: PagingDataStructure<T>) {
    
    let contentOffset: CGPoint = collectionView.contentOffset
    let itemsWidth = diffWidth(
      from: oldValue.visibleItems,
      to: dataStructure.visibleItems)
    
    collectionViewLayout.dataStructure = dataStructure
    collectionView.reloadData()
    collectionView.contentOffset = CGPoint(
      x: contentOffset.x + itemsWidth,
      y: contentOffset.y)
  }
  
  private func selectViewController(pagingItem: T, direction: PagingDirection, animated: Bool = true) {
    guard let dataSource = dataSource else { return }
    let viewController = dataSource.viewControllerForPagingItem(pagingItem)
    pageViewController.selectViewController(viewController,
                                            direction: direction.pageViewControllerNavigationDirection,
                                            animated: animated,
                                            completion: nil)
  }
  
  private func selectCollectionViewCell(pagingItem: T, scrollPosition: UICollectionViewScrollPosition, animated: Bool = false) {
    let indexPath = dataStructure.indexPathForPagingItem(pagingItem)
    collectionView.selectItemAtIndexPath(indexPath,
                                         animated: animated,
                                         scrollPosition: scrollPosition)
  }
  
  // MARK: UICollectionViewDelegateFlowLayout
  
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if case .SizeToFit = options.menuItemSize {
      let width = dataStructure.visibleItems.reduce(0) { widthForPagingItem($0.1) + $0.0 }
      if width < collectionView.bounds.width {
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

    stateMachine.fire(.Select(pagingItem: selectedPagingItem, direction: direction))
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
  
  // MARK: EMPageViewControllerDataSource
  
  public func em_pageViewController(pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    guard
      let dataSource = dataSource,
      let state = stateMachine?.state.currentPagingItem,
      let pagingItem = dataSource.pagingItemBeforePagingItem(state) else { return nil }
    
    return dataSource.viewControllerForPagingItem(pagingItem)
  }
  
  public func em_pageViewController(pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
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
      return minWidth
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
    return dataSource?.pagingItemBeforePagingItem(pagingItem) as? U
  }
  
  func pagingStateMachine<U>(
    pagingStateMachine: PagingStateMachine<U>,
    pagingItemAfterPagingItem pagingItem: U) -> U? {
    guard let pagingItem = pagingItem as? T else { return nil }
    return dataSource?.pagingItemAfterPagingItem(pagingItem) as? U
  }
  
}
