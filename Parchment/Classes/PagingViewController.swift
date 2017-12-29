import UIKit

/// A view controller that lets you to page between views while
/// showing menu items that scrolls along with the content. When using
/// this class you need to provide a generic type that conforms to the
/// `PagingItem` protocol.
///
/// The data source object is responsible for actually generating the
/// `PagingItem` as well as allocating the view controller that
/// corresponds to each item. See `PagingViewControllerDataSource`.
///
/// After providing a data source you need to call
/// `selectPagingItem(pagingItem:animated:)` to set the initial view
/// controller. You can also use the same method to programmatically
/// navigate to other view controllers.
open class PagingViewController<T: PagingItem>:
  UIViewController,
  UICollectionViewDataSource,
  UICollectionViewDelegate,
  EMPageViewControllerDataSource,
  EMPageViewControllerDelegate,
  PagingSizeCacheDelegate,
  PagingStateMachineDelegate where T: Hashable, T: Comparable {

  /// The size for each of the menu items. _Default:
  /// .sizeToFit(minWidth: 150, height: 40)_
  open var menuItemSize: PagingMenuItemSize {
    get { return options.menuItemSize }
    set { options.menuItemSize = newValue }
  }

  /// The class type for the menu item. Override this if you want
  /// your own custom menu items. _Default: PagingTitleCell.self_
  open var menuItemClass: PagingCell.Type {
    get { return options.menuItemClass }
    set { options.menuItemClass = newValue }
  }

  /// Determine the spacing between the menu items. _Default: 0_
  open var menuItemSpacing: CGFloat {
    get { return options.menuItemSpacing }
    set { options.menuItemSpacing = newValue }
  }

  /// Determine the insets at around all the menu items. _Default:
  /// UIEdgeInsets.zero_
  open var menuInsets: UIEdgeInsets {
    get { return options.menuInsets }
    set { options.menuInsets = newValue }
  }

  /// Determine whether the menu items should be centered when all the
  /// items can fit within the bounds of the view. _Default: .left_
  open var menuHorizontalAlignment: PagingMenuHorizontalAlignment {
    get { return options.menuHorizontalAlignment }
    set { options.menuHorizontalAlignment = newValue }
  }

  /// Determine the transition behaviour of menu items while scrolling
  /// the content. _Default: .scrollAlongside_
  open var menuTransition: PagingMenuTransition {
    get { return options.menuTransition }
    set { options.menuTransition = newValue }
  }

  /// Determine how users can interact with the menu items.
  /// _Default: .scrolling_
  open var menuInteraction: PagingMenuInteraction {
    get { return options.menuInteraction }
    set {
      options.menuInteraction = newValue
      configureMenuInteraction()
    }
  }

  /// Determine how the selected menu item should be aligned when it
  /// is selected. Effectivly the same as the
  /// `UICollectionViewScrollPosition`. _Default: .preferCentered_
  open var selectedScrollPosition: PagingSelectedScrollPosition {
    get { return options.selectedScrollPosition }
    set { options.selectedScrollPosition = newValue }
  }

  /// Add a indicator view to the selected menu item. The indicator
  /// width will be equal to the selected menu items width. Insets
  /// only apply horizontally. _Default: .visible_
  open var indicatorOptions: PagingIndicatorOptions {
    get { return options.indicatorOptions }
    set { options.indicatorOptions = newValue }
  }

  /// The class type for the indicator view. Override this if you want
  /// your use your own subclass of PagingIndicatorView. _Default:
  /// PagingIndicatorView.self_
  open var indicatorClass: PagingIndicatorView.Type {
    get { return options.indicatorClass }
    set { options.indicatorClass = newValue }
  }

  /// Determine the color of the indicator view.
  open var indicatorColor: UIColor {
    get { return options.theme.indicatorColor }
    set { options.theme.indicatorColor = newValue }
  }
  
  /// Add a border at the bottom of the menu items. The border will be
  /// as wide as all the menu items. Insets only apply horizontally.
  /// _Default: .visible_
  open var borderOptions: PagingBorderOptions {
    get { return options.borderOptions }
    set { options.borderOptions = newValue }
  }

  /// The class type for the border view. Override this if you want
  /// your use your own subclass of PagingBorderView. _Default:
  /// PagingBorderView.self_
  open var borderClass: PagingBorderView.Type {
    get { return options.borderClass }
    set { options.borderClass = newValue }
  }
  
  /// Determine the color of the border view.
  open var borderColor: UIColor {
    get { return options.theme.borderColor }
    set { options.theme.borderColor = newValue }
  }

  /// Updates the content inset for the menu items based on the
  /// .safeAreaInsets property. _Default: true_
  open var includeSafeAreaInsets: Bool {
    get { return options.includeSafeAreaInsets }
    set { options.includeSafeAreaInsets = newValue }
  }

  /// The font used for title label on the menu items.
  open var font: UIFont {
    get { return options.theme.font }
    set { options.theme.font = newValue }
  }

  /// The color of the title label on the menu items.
  open var textColor: UIColor {
    get { return options.theme.textColor }
    set { options.theme.textColor = newValue }
  }

  /// The text color for the currently selected menu item.
  open var selectedTextColor: UIColor {
    get { return options.theme.selectedTextColor }
    set { options.theme.selectedTextColor = newValue }
  }

  /// The background color for the menu items.
  open var backgroundColor: UIColor {
    get { return options.theme.backgroundColor }
    set { options.theme.backgroundColor = newValue }
  }

  /// The background color for the header view behind the menu items.
  open var headerBackgroundColor: UIColor {
    get { return options.theme.headerBackgroundColor }
    set { options.theme.headerBackgroundColor = newValue }
  }
  
  /// The data source is responsible for providing the `PagingItem`s
  /// that are displayed in the menu. The `PagingItem` protocol is
  /// used to generate menu items for all the view controllers,
  /// without having to actually allocate them before they are needed.
  /// Use this property when you have a fixed amount of view
  /// controllers. If you need to support infinitely large data
  /// sources, use the infiniteDataSource property instead.
  open weak var dataSource: PagingViewControllerDataSource? {
    didSet {
      configureDataSource()
    }
  }
  
  /// A data source that can be used when you need to support
  /// infinitely large data source by returning the `PagingItem`
  /// before or after a given `PagingItem`. The `PagingItem` protocol
  /// is used to generate menu items for all the view controllers,
  /// without having to actually allocate them before they are needed.
  open weak var infiniteDataSource: PagingViewControllerInfiniteDataSource?

  /// Use this delegate if you want to manually control the width of
  /// your menu items. Self-sizing cells is not supported at the
  /// moment, so you have to use this if you have a custom cell that
  /// you want to size based on its content.
  open weak var delegate: PagingViewControllerDelegate? {
    didSet {
      sizeCache.delegate = self
      sizeCache.implementsWidthDelegate = true
    }
  }

  /// A custom collection view layout that lays out all the menu items
  /// horizontally. See the `PagingOptions` protocol on how you can
  /// customize the layout.
  open lazy var collectionViewLayout: PagingCollectionViewLayout<T> = {
    return PagingCollectionViewLayout(
      options: self.options,
      dataStructure: self.dataStructure,
      sizeCache: self.sizeCache)
  }()

  /// Used to display the menu items that scrolls along with the
  /// content. Using a collection view means you can create custom
  /// cells that display pretty much anything. By default, scrolling
  /// is enabled in the collection view. See `PagingOptions` for more
  /// details on what you can customize.
  open lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
    collectionView.backgroundColor = .white
    collectionView.showsHorizontalScrollIndicator = false
    return collectionView
  }()

  /// Used to display the view controller that you are paging
  /// between. Instead of using UIPageViewController we use a library
  /// called EMPageViewController which fixes a lot of the common
  /// issues with using UIPageViewController.
  open let pageViewController: EMPageViewController = {
    return EMPageViewController(navigationOrientation: .horizontal)
  }()

  /// An instance that stores all the customization so that it's
  /// easier to share between other classes. You should use the
  /// customization properties on PagingViewController, instead of
  /// setting values on this class directly.
  open let options: PagingOptions
  
  fileprivate let sizeCache: PagingSizeCache<T>
  fileprivate var swipeGestureRecognizerLeft: UISwipeGestureRecognizer?
  fileprivate var swipeGestureRecognizerRight: UISwipeGestureRecognizer?
  fileprivate var didLayoutSubviews: Bool = false
  fileprivate var dataStructure: PagingDataStructure<T>
  fileprivate var indexedDataSource: IndexedPagingDataSource<T>?
  
  fileprivate var stateMachine: PagingStateMachine<T>? {
    didSet {
      handleStateMachineUpdate()
    }
  }
  
  fileprivate let PagingCellReuseIdentifier = "PagingCellReuseIdentifier"

  /// Creates an instance of `PagingViewController`. You need to call
  /// `selectPagingItem(pagingItem:animated:)` in order to set the
  /// initial view controller before any items become visible.
  public init() {
    self.options = PagingOptions()
    self.dataStructure = PagingDataStructure(visibleItems: [])
    self.sizeCache = PagingSizeCache(options: options)
    super.init(nibName: nil, bundle: nil)
  }

  /// Creates an instance of `PagingViewController`.
  ///
  /// - Parameter coder: An unarchiver object.
  required public init?(coder: NSCoder) {
    self.options = PagingOptions()
    self.dataStructure = PagingDataStructure(visibleItems: [])
    self.sizeCache = PagingSizeCache(options: self.options)
    super.init(coder: coder)
  }
  
  /// Reload data around given paging item. This will set the given
  /// paging item as selected and generate new items around it. This
  /// will also reload the view controllers displayed in the page view
  /// controller.
  ///
  /// - Parameter pagingItem: The `PagingItem` that will be selected
  /// after the data reloads.
  open func reloadData(around pagingItem: T) {
    guard let stateMachine = stateMachine else { return }
    stateMachine.fire(.select(
      pagingItem: pagingItem,
      direction: .none,
      animated: false))
    reloadItems(around: pagingItem)
  }

  /// Selects a given paging item. This need to be called after you
  /// initilize the `PagingViewController` to set the initial
  /// `PagingItem`. This can be called both before and after the view
  /// has been loaded. You can also use this to programmatically
  /// navigate to another `PagingItem`.
  ///
  /// - Parameter pagingItem: The `PagingItem` to be displayed.
  /// - Parameter animated: A boolean value that indicates whether
  /// the transtion should be animated. Default is false.
  open func selectPagingItem(_ pagingItem: T, animated: Bool = false) {

    if let stateMachine = stateMachine,
      let indexPath = dataStructure.indexPathForPagingItem(pagingItem) {
      let direction = dataStructure.directionForIndexPath(indexPath, currentPagingItem: pagingItem)
      stateMachine.fire(.select(
        pagingItem: pagingItem,
        direction: direction,
        animated: animated))
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
          reloadItems(around: state.currentPagingItem)
        }
      }
    }
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
    pageViewController.delegate = self
    pageViewController.dataSource = self
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(options.menuItemClass, forCellWithReuseIdentifier: PagingCellReuseIdentifier)
    collectionViewLayout.registerDecorationViews()
    configureMenuInteraction()
    
    if let state = stateMachine?.state {
      selectViewController(
        state.currentPagingItem,
        direction: .none,
        animated: false)
    }
    
    if #available(iOS 11.0, *) {
      pageViewController.scrollView.contentInsetAdjustmentBehavior = .never
      collectionView.contentInsetAdjustmentBehavior = .never
    }
  }
  
  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard let state = stateMachine?.state else { return }
    
    // We need generate the menu items when the view appears for the
    // first time. Doing it in viewWillAppear does not work as the
    // safeAreaInsets will not be updated yet.
    if didLayoutSubviews == false {
      reloadItems(around: state.currentPagingItem)
      selectCollectionViewItem(for: state.currentPagingItem)
      didLayoutSubviews = true
    }
  }
  
  open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    guard let stateMachine = stateMachine else { return }
    
    coordinator.animate(alongsideTransition: { context in
      stateMachine.fire(.transitionSize)
      let pagingItem = stateMachine.state.currentPagingItem
      self.reloadItems(around: pagingItem)
      self.selectCollectionViewItem(for: pagingItem)
    }, completion: nil)
  }
  
  // MARK: Private
  
  fileprivate func configureDataSource() {
    guard let dataSource = dataSource else { return }
    
    let numberOfItems = dataSource.numberOfViewControllers(in: self)
    let items = (0..<numberOfItems).enumerated().map {
      dataSource.pagingViewController(self, pagingItemForIndex: $0.offset)
    }
    
    indexedDataSource = IndexedPagingDataSource(items: items) {
      return dataSource.pagingViewController(self, viewControllerForIndex: $0)
    }
    
    infiniteDataSource = indexedDataSource

    if let firstItem = items.first {
      selectPagingItem(firstItem)
    }
  }
  
  fileprivate func configureMenuInteraction() {
    collectionView.isScrollEnabled = false
    collectionView.alwaysBounceHorizontal = false
    
    if let swipeGestureRecognizerLeft = swipeGestureRecognizerLeft {
      collectionView.removeGestureRecognizer(swipeGestureRecognizerLeft)
    }
    
    if let swipeGestureRecognizerRight = swipeGestureRecognizerRight {
      collectionView.removeGestureRecognizer(swipeGestureRecognizerRight)
    }
    
    switch (options.menuInteraction) {
    case .scrolling:
      collectionView.isScrollEnabled = true
      collectionView.alwaysBounceHorizontal = true
    case .swipe:
      setupGestureRecognizers()
    case .none:
      break
    }
  }
  
  fileprivate func setupGestureRecognizers() {
    let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer))
    swipeGestureRecognizerLeft.direction = .left
    
    let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer))
    swipeGestureRecognizerRight.direction = .right
    
    collectionView.addGestureRecognizer(swipeGestureRecognizerLeft)
    collectionView.addGestureRecognizer(swipeGestureRecognizerRight)
    
    self.swipeGestureRecognizerLeft = swipeGestureRecognizerLeft
    self.swipeGestureRecognizerRight = swipeGestureRecognizerRight
  }
  
  @objc fileprivate dynamic func handleSwipeGestureRecognizer(_ recognizer: UISwipeGestureRecognizer) {
    guard let stateMachine = stateMachine else { return }
    
    let currentPagingItem = stateMachine.state.currentPagingItem
    var upcomingPagingItem: T? = nil
    
    if recognizer.direction.contains(.left) {
      upcomingPagingItem = infiniteDataSource?.pagingViewController(self, pagingItemAfterPagingItem: currentPagingItem)
    } else if recognizer.direction.contains(.right) {
      upcomingPagingItem = infiniteDataSource?.pagingViewController(self, pagingItemBeforePagingItem: currentPagingItem)
    }
    
    if let item = upcomingPagingItem {
      selectPagingItem(item, animated: true)
    }
  }
  
  fileprivate func handleStateUpdate(_ oldState: PagingState<T>, state: PagingState<T>, event: PagingEvent<T>?) {
    collectionViewLayout.state = state
    
    switch state {
    case let .selected(pagingItem):
      if let event = event {
        switch event {
        case .finishScrolling, .transitionSize:
          
          // We only want to select the current paging item
          // if the user is not scrolling the collection view.
          if collectionView.isDragging == false {
            let animated = options.menuTransition == .animateAfter
            reloadItems(around: pagingItem)
            selectCollectionViewItem(for: pagingItem, animated: animated)
          }
        default:
          break
        }
      }
    case .scrolling:
      let invalidationContext = PagingInvalidationContext()
      
      // We don't want to update the content offset if there is no
      // upcoming item to scroll to. We need to invalidate the layout
      // though in order to update the layout attributes for the
      // decoration views.
      if let upcomingPagingItem = state.upcomingPagingItem {
        
        // When the old state is .selected it means that the user
        // just started scrolling.
        if case .selected = oldState {
          invalidationContext.invalidateTransition = true
          
          // Stop any ongoing scrolling so that the isDragging
          // property is set to false in case the collection
          // view is still scrolling after a swipe.
          stopScrolling()
          
          // If the upcoming item is outside the currently visible
          // items we need to append the items that are around the
          // upcoming item so we can animate the transition.
          if dataStructure.visibleItems.contains(upcomingPagingItem) == false {
            reloadItems(around: upcomingPagingItem, keepExisting: true)
          }
        }
        
        invalidationContext.invalidateContentOffset = true
        
        if sizeCache.implementsWidthDelegate {
          invalidationContext.invalidateSizes = true
        }
      }
      
      // We don't want to update the content offset while the
      // user is dragging in the collection view.
      if collectionView.isDragging == false {
        collectionViewLayout.invalidateLayout(with: invalidationContext)
      }
    }
  }
  
  fileprivate func handleStateMachineUpdate() {
    stateMachine?.didSelectPagingItem = { [weak self] pagingItem, direction, animated in
      self?.selectViewController(pagingItem, direction: direction, animated: animated)
    }
    
    stateMachine?.didChangeState = { [weak self] oldState, state, event in
      self?.handleStateUpdate(oldState, state: state, event: event)
    }
    
    stateMachine?.delegate = self
  }
  
  fileprivate func selectCollectionViewItem(for pagingItem: T, animated: Bool = false) {
    let indexPath = dataStructure.indexPathForPagingItem(pagingItem)
    let scrollPosition = options.scrollPosition
    
    collectionView.selectItem(
      at: indexPath,
      animated: animated,
      scrollPosition: scrollPosition)
  }
  
  fileprivate func generateItems(around pagingItem: T) -> Set<T> {
    
    var items: Set = [pagingItem]
    var previousItem: T = pagingItem
    var nextItem: T = pagingItem
    
    // Add as many items as we can before the current paging item to
    // fill up the same width as the bounds.
    var widthBefore: CGFloat = collectionView.bounds.width
    while widthBefore > 0 {
      if let item = infiniteDataSource?.pagingViewController(self, pagingItemBeforePagingItem: previousItem) {
        widthBefore -= itemWidth(pagingItem: item)
        previousItem = item
        items.insert(item)
      } else {
        break
      }
    }
    
    // When filling up the items after the current item we need to
    // include any remaining space left before the current item.
    var widthAfter: CGFloat = collectionView.bounds.width + widthBefore
    while widthAfter > 0 {
      if let item = infiniteDataSource?.pagingViewController(self, pagingItemAfterPagingItem: nextItem) {
        widthAfter -= itemWidth(pagingItem: item)
        nextItem = item
        items.insert(item)
      } else {
        break
      }
    }
    
    // Make sure we add even more items if there is any remaining
    // space available after filling items items after the current.
    var remainingWidth = widthAfter
    while remainingWidth > 0 {
      if let item = infiniteDataSource?.pagingViewController(self, pagingItemBeforePagingItem: previousItem) {
        remainingWidth -= itemWidth(pagingItem: item)
        previousItem = item
        items.insert(item)
      } else {
        break
      }
    }
    
    return items
  }
  
  fileprivate func reloadItems(around pagingItem: T, keepExisting: Bool = false) {
    var toItems = generateItems(around: pagingItem)
    
    if keepExisting {
      toItems = dataStructure.visibleItems.union(toItems)
    }
  
    let oldLayoutAttributes = collectionViewLayout.layoutAttributes
    let oldContentOffset = collectionView.contentOffset
    let oldDataStructure = dataStructure
    let sortedItems = Array(toItems).sorted()
    
    dataStructure = PagingDataStructure(
      visibleItems: toItems,
      hasItemsBefore: hasItemBefore(pagingItem: sortedItems.first),
      hasItemsAfter: hasItemAfter(pagingItem: sortedItems.last))
    
    collectionViewLayout.dataStructure = dataStructure
    collectionView.reloadData()
    collectionViewLayout.prepare()
    
    // After reloading the data the content offset is going to be
    // reset. We need to diff which items where added/removed and
    // update the content offset so it looks it is the same as before
    // reloading. This gives the perception of a smooth scroll.
    var offset: CGFloat = 0
    let diff = PagingDiff(from: oldDataStructure, to: dataStructure)
    
    for indexPath in diff.removed() {
      offset += oldLayoutAttributes[indexPath]?.frame.width ?? 0
      offset += options.menuItemSpacing
    }
    
    for indexPath in diff.added() {
      offset -= collectionViewLayout.layoutAttributes[indexPath]?.frame.width ?? 0
      offset -= options.menuItemSpacing
    }
    
    collectionView.contentOffset = CGPoint(
      x: oldContentOffset.x - offset,
      y: oldContentOffset.y)
    
    // Update the transition state for the layout in case there is
    // already a transition in progress.
    collectionViewLayout.updateCurrentTransition()
    
    // We need to perform layout here, if not the collection view
    // seems to get in a weird state.
    collectionView.layoutIfNeeded()
  }
  
  fileprivate func selectViewController(_ pagingItem: T, direction: PagingDirection, animated: Bool = true) {
    guard let dataSource = infiniteDataSource else { return }
    pageViewController.selectViewController(
      dataSource.pagingViewController(self, viewControllerForPagingItem: pagingItem),
      direction: direction.pageViewControllerNavigationDirection,
      animated: animated,
      completion: nil)
  }
  
  fileprivate func itemWidth(pagingItem: T) -> CGFloat {
    guard let state = stateMachine?.state else { return options.estimatedItemWidth }

    if state.currentPagingItem == pagingItem {
      return sizeCache.itemWidthSelected(for: pagingItem)
    } else {
      return sizeCache.itemWidth(for: pagingItem)
    }
  }
  
  fileprivate func hasItemBefore(pagingItem: T?) -> Bool {
    guard let item = pagingItem else { return false }
    return infiniteDataSource?.pagingViewController(self, pagingItemBeforePagingItem: item) != nil
  }
  
  fileprivate func hasItemAfter(pagingItem: T?) -> Bool {
    guard let item = pagingItem else { return false }
    return infiniteDataSource?.pagingViewController(self, pagingItemAfterPagingItem: item) != nil
  }
  
  fileprivate func stopScrolling() {
    collectionView.setContentOffset(collectionView.contentOffset, animated: false)
  }

  // MARK: UICollectionViewDelegate
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    // If we don't have any visible items there is no point in
    // checking if we're near an edge. This seems to be empty quite
    // often when scrolling very fast.
    if collectionView.indexPathsForVisibleItems.isEmpty {
      return
    }
    
    if scrollView.near(edge: .left) {
      if let firstPagingItem = dataStructure.sortedItems.first {
        if dataStructure.hasItemsBefore {
          reloadItems(around: firstPagingItem)
        }
      }
    } else if scrollView.near(edge: .right) {
      if let lastPagingItem = dataStructure.sortedItems.last {
        if dataStructure.hasItemsAfter {
          reloadItems(around: lastPagingItem)
        }
      }
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
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagingCellReuseIdentifier, for: indexPath) as! PagingCell
    let pagingItem = dataStructure.sortedItems[indexPath.item]
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
      let dataSource = infiniteDataSource,
      let state = stateMachine?.state.currentPagingItem,
      let pagingItem = dataSource.pagingViewController(self, pagingItemBeforePagingItem: state) else { return nil }
    
    return dataSource.pagingViewController(self, viewControllerForPagingItem: pagingItem)
  }
  
  open func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    guard
      let dataSource = infiniteDataSource,
      let state = stateMachine?.state.currentPagingItem,
      let pagingItem = dataSource.pagingViewController(self, pagingItemAfterPagingItem: state) else { return nil }
    
    return dataSource.pagingViewController(self, viewControllerForPagingItem: pagingItem)
  }
  
  // MARK: EMPageViewControllerDelegate

  open func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {
    // EMPageViewController will trigger a scrolling event even if the
    // view has not appeared, causing the wrong initial paging item.
    if view.window != nil {
      stateMachine?.fire(.scroll(progress: progress))
    }
  }
  
  open func em_pageViewController(_ pageViewController: EMPageViewController, willStartScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController) {
    return
  }
  
  open func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
    guard let state = stateMachine?.state else { return }
    
    if transitionSuccessful {
      // If a transition finishes scrolling, but the upcoming paging
      // item is nil it means that the user scrolled away from one of
      // the items at the very edge. In this case, we don't want to
      // fire a .finishScrolling event as this will select the current
      // paging item, causing it to jump to that item even if it's
      // scrolled out of view. We still need to fire an event that
      // will reset the state to .selected.
      if state.upcomingPagingItem == nil {
        stateMachine?.fire(.cancelScrolling)
      } else {
        stateMachine?.fire(.finishScrolling)
      }
    }
  }
  
  // MARK: PagingStateMachineDelegate
  
  func pagingStateMachine<U>(_ pagingStateMachine: PagingStateMachine<U>, pagingItemBeforePagingItem pagingItem: U) -> U? {
    guard let pagingItem = pagingItem as? T else { return nil }
    return infiniteDataSource?.pagingViewController(self, pagingItemBeforePagingItem: pagingItem) as? U
  }
  
  func pagingStateMachine<U>(_ pagingStateMachine: PagingStateMachine<U>, pagingItemAfterPagingItem pagingItem: U) -> U? {
    guard let pagingItem = pagingItem as? T else { return nil }
    return infiniteDataSource?.pagingViewController(self, pagingItemAfterPagingItem: pagingItem) as? U
  }
  
  // MARK: PagingSizeCacheDelegate
  
  func pagingSizeCache<U>(_ pagingSizeCache: PagingSizeCache<U>, widthForPagingItem pagingItem: U, isSelected: Bool) -> CGFloat? {
    guard let pagingItem = pagingItem as? T else { return nil }
    return delegate?.pagingViewController(self, widthForPagingItem: pagingItem, isSelected: isSelected)
  }
  
}
