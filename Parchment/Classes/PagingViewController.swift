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
/// `select(pagingItem:animated:)` to set the initial view controller.
/// You can also use the same method to programmatically navigate to
/// other view controllers.
open class PagingViewController<T: PagingItem>:
  UIViewController,
  UICollectionViewDataSource,
  UICollectionViewDelegate,
  EMPageViewControllerDataSource,
  EMPageViewControllerDelegate,
  PagingSizeCacheDelegate,
  PagingStateMachineDelegate where T: Hashable, T: Comparable {

  /// The class type for collection view layout. Override this if you
  /// want to use your own subclass of the layout.
  /// _Default: PagingCollectionViewLayout.self_
  open var menuLayoutClass: PagingCollectionViewLayout<T>.Type = PagingCollectionViewLayout.self
  
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
  
  /// The current state of the menu items. Indicates whether an item
  /// is currently selected or is scrolling to another item. Can be
  /// used to get the distance and progress of any ongoing transition.
  public private(set) var state: PagingState<T> = .empty
  
  public private(set) var visibleItems: PagingItems<T>
  
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
      configureSizeCache()
    }
  }
  
  /// A custom collection view layout that lays out all the menu items
  /// horizontally. See the `PagingOptions` protocol on how you can
  /// customize the layout.
  open private(set) var collectionViewLayout: PagingCollectionViewLayout<T>?

  /// Used to display the menu items that scrolls along with the
  /// content. Using a collection view means you can create custom
  /// cells that display pretty much anything. By default, scrolling
  /// is enabled in the collection view. See `PagingOptions` for more
  /// details on what you can customize.
  open private(set) var collectionView: UICollectionView?

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
  fileprivate let stateMachine: PagingStateMachine<T>
  fileprivate var swipeGestureRecognizerLeft: UISwipeGestureRecognizer?
  fileprivate var swipeGestureRecognizerRight: UISwipeGestureRecognizer?
  fileprivate var didLayoutSubviews: Bool = false
  fileprivate var indexedDataSource: IndexedPagingDataSource<T>?
  
  private var pagingView: PagingView {
    return view as! PagingView
  }
  
  fileprivate let PagingCellReuseIdentifier = "PagingCellReuseIdentifier"

  /// Creates an instance of `PagingViewController`. You need to call
  /// `select(pagingItem:animated:)` in order to set the initial view
  /// controller before any items become visible.
  public init() {
    self.options = PagingOptions()
    self.visibleItems = PagingItems(items: [])
    self.sizeCache = PagingSizeCache(options: options)
    self.stateMachine = PagingStateMachine(initialState: .empty)
    super.init(nibName: nil, bundle: nil)
    configureStateMachine()
  }

  /// Creates an instance of `PagingViewController`.
  ///
  /// - Parameter coder: An unarchiver object.
  required public init?(coder: NSCoder) {
    self.options = PagingOptions()
    self.visibleItems = PagingItems(items: [])
    self.sizeCache = PagingSizeCache(options: self.options)
    self.stateMachine = PagingStateMachine(initialState: .empty)
    super.init(coder: coder)
    configureStateMachine()
  }
  
  /// Reload data around given paging item. This will set the given
  /// paging item as selected and generate new items around it. This
  /// will also reload the view controllers displayed in the page view
  /// controller.
  ///
  /// - Parameter pagingItem: The `PagingItem` that will be selected
  /// after the data reloads.
  open func reloadData(around pagingItem: T) {
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
  open func select(pagingItem: T, animated: Bool = false) {
    switch (state) {
    case .empty:
      stateMachine.fire(.select(
        pagingItem: pagingItem,
        direction: .none,
        animated: false))
      
      if isViewLoaded {
        selectViewController(
          pagingItem,
          direction: .none,
          animated: false)
        
        if view.window != nil {
          reloadItems(around: pagingItem)
        }
      }
    default:
      guard let currentPagingItem = state.currentPagingItem else { return }
      let direction = visibleItems.direction(from: currentPagingItem, to: pagingItem)
      stateMachine.fire(.select(
        pagingItem: pagingItem,
        direction: direction,
        animated: animated))
    }
  }

  open override func loadView() {
    view = PagingView(options: options)
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    let collectionViewLayout = createLayout(layout: menuLayoutClass.self, options: options)
    collectionViewLayout.visibleItems = visibleItems
    collectionViewLayout.sizeCache = sizeCache
    collectionViewLayout.state = state
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.backgroundColor = .white
    collectionView.showsHorizontalScrollIndicator = false
    
    self.collectionView = collectionView
    self.collectionViewLayout = collectionViewLayout
    
    addChildViewController(pageViewController)
    pagingView.configure(collectionView: collectionView, pageView: pageViewController.view)
    pageViewController.didMove(toParentViewController: self)
    pageViewController.delegate = self
    pageViewController.dataSource = self
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(options.menuItemClass, forCellWithReuseIdentifier: PagingCellReuseIdentifier)
    collectionViewLayout.registerDecorationViews()
    configureMenuInteraction()
    
    if let currentPagingItem = state.currentPagingItem {
      selectViewController(
        currentPagingItem,
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
    guard let currentPagingItem = state.currentPagingItem else { return }
    
    // We need generate the menu items when the view appears for the
    // first time. Doing it in viewWillAppear does not work as the
    // safeAreaInsets will not be updated yet.
    if didLayoutSubviews == false {
      reloadItems(around: currentPagingItem)
      selectCollectionViewItem(for: currentPagingItem)
      didLayoutSubviews = true
    }
  }
  
  open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { [weak self] context in
      self?.stateMachine.fire(.transitionSize)
      if let pagingItem = self?.state.currentPagingItem {
        self?.reloadItems(around: pagingItem)
        self?.selectCollectionViewItem(for: pagingItem)
      }
    }, completion: nil)
  }
  
  // MARK: Private
  
  fileprivate func configureSizeCache() {
    if let delegate = delegate, let currentPagingItem = state.currentPagingItem {
      sizeCache.delegate = self
      if let _ = delegate.pagingViewController(self, widthForPagingItem: currentPagingItem, isSelected: false) {
        sizeCache.implementsWidthDelegate = true
      }
    }
  }
  
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
      select(pagingItem: firstItem)
    }
  }
  
  fileprivate func configureMenuInteraction() {
    collectionView?.isScrollEnabled = false
    collectionView?.alwaysBounceHorizontal = false
    
    if let swipeGestureRecognizerLeft = swipeGestureRecognizerLeft {
      collectionView?.removeGestureRecognizer(swipeGestureRecognizerLeft)
    }
    
    if let swipeGestureRecognizerRight = swipeGestureRecognizerRight {
      collectionView?.removeGestureRecognizer(swipeGestureRecognizerRight)
    }
    
    switch (options.menuInteraction) {
    case .scrolling:
      collectionView?.isScrollEnabled = true
      collectionView?.alwaysBounceHorizontal = true
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
    
    collectionView?.addGestureRecognizer(swipeGestureRecognizerLeft)
    collectionView?.addGestureRecognizer(swipeGestureRecognizerRight)
    
    self.swipeGestureRecognizerLeft = swipeGestureRecognizerLeft
    self.swipeGestureRecognizerRight = swipeGestureRecognizerRight
  }
  
  @objc fileprivate dynamic func handleSwipeGestureRecognizer(_ recognizer: UISwipeGestureRecognizer) {
    guard let currentPagingItem = state.currentPagingItem else { return }
    
    var upcomingPagingItem: T? = nil
    
    if recognizer.direction.contains(.left) {
      upcomingPagingItem = infiniteDataSource?.pagingViewController(self, pagingItemAfterPagingItem: currentPagingItem)
    } else if recognizer.direction.contains(.right) {
      upcomingPagingItem = infiniteDataSource?.pagingViewController(self, pagingItemBeforePagingItem: currentPagingItem)
    }
    
    if let item = upcomingPagingItem {
      select(pagingItem: item, animated: true)
    }
  }
  
  fileprivate func handleStateUpdate(_ oldState: PagingState<T>, state: PagingState<T>, event: PagingEvent<T>?) {
    self.state = state
    collectionViewLayout?.state = state

    switch state {
    case let .selected(pagingItem):
      if let event = event {
        switch event {
        case .finishScrolling, .transitionSize:
          
          // We only want to select the current paging item
          // if the user is not scrolling the collection view.
          if collectionView?.isDragging == false {
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
      // upcoming item to scroll to. We stil need to invalidate the
      // layout in order to update the layout attributes for the
      // decoration views.
      if state.upcomingPagingItem != nil {
        invalidateContentOffset()
        
        if sizeCache.implementsWidthDelegate {
          invalidationContext.invalidateSizes = true
        }
      }
      
      collectionViewLayout?.invalidateLayout(with: invalidationContext)
    case .empty:
      break
    }
  }
  
  fileprivate func configureStateMachine() {
    stateMachine.didSelectPagingItem = { [weak self] pagingItem, direction, animated in
      self?.selectViewController(pagingItem, direction: direction, animated: animated)
    }
    
    stateMachine.didChangeState = { [weak self] oldState, state, event in
      self?.handleStateUpdate(oldState, state: state, event: event)
    }
    
    stateMachine.delegate = self
    
    configureSizeCache()
  }
  
  fileprivate func selectCollectionViewItem(for pagingItem: T, animated: Bool = false) {
    let indexPath = visibleItems.indexPath(for: pagingItem)
    let scrollPosition = options.scrollPosition
    
    collectionView?.selectItem(
      at: indexPath,
      animated: animated,
      scrollPosition: scrollPosition)
  }

  fileprivate func invalidateContentOffset() {
    guard let collectionView = collectionView else { return }
    
    if options.menuTransition == .scrollAlongside {
      if case let .scrolling(_, _, progress, initialContentOffset, distance) = state {
        if collectionView.contentSize.width >= collectionView.bounds.width && state.progress != 0 {
          let contentOffset = CGPoint(
            x: initialContentOffset.x + (distance * fabs(progress)),
            y: initialContentOffset.y)
          
          // We need to use setContentOffset with no animation in
          // order to stop any ongoing scroll.
          collectionView.setContentOffset(contentOffset, animated: false)
        }
      }
    }
  }
  
  fileprivate func generateItems(around pagingItem: T) -> Set<T> {
    
    var items: Set = [pagingItem]
    var previousItem: T = pagingItem
    var nextItem: T = pagingItem
    let menuWidth = collectionView?.bounds.width ?? 0
    
    // Add as many items as we can before the current paging item to
    // fill up the same width as the bounds.
    var widthBefore: CGFloat = menuWidth
    while widthBefore > 0 {
      if let item = infiniteDataSource?.pagingViewController(self, pagingItemBeforePagingItem: previousItem) {
        widthBefore -= itemWidth(pagingItem: item)
        widthBefore -= options.menuItemSpacing
        previousItem = item
        items.insert(item)
      } else {
        break
      }
    }
    
    // When filling up the items after the current item we need to
    // include any remaining space left before the current item.
    var widthAfter: CGFloat = menuWidth + widthBefore
    while widthAfter > 0 {
      if let item = infiniteDataSource?.pagingViewController(self, pagingItemAfterPagingItem: nextItem) {
        widthAfter -= itemWidth(pagingItem: item)
        widthAfter -= options.menuItemSpacing
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
        remainingWidth -= options.menuItemSpacing
        previousItem = item
        items.insert(item)
      } else {
        break
      }
    }
    
    return items
  }
  
  fileprivate func reloadItems(around pagingItem: T, keepExisting: Bool = false) {
    guard
      let collectionView = collectionView,
      let collectionViewLayout = collectionViewLayout else { return }
    
    var toItems = generateItems(around: pagingItem)
    
    if keepExisting {
      toItems = visibleItems.itemsCache.union(toItems)
    }
  
    let oldLayoutAttributes = collectionViewLayout.layoutAttributes
    let oldContentOffset = collectionView.contentOffset
    let oldVisibleItems = visibleItems
    let sortedItems = Array(toItems).sorted()
    
    visibleItems = PagingItems(
      items: sortedItems,
      hasItemsBefore: hasItemBefore(pagingItem: sortedItems.first),
      hasItemsAfter: hasItemAfter(pagingItem: sortedItems.last))
    
    collectionViewLayout.visibleItems = visibleItems
    collectionView.reloadData()
    collectionViewLayout.prepare()
    
    // After reloading the data the content offset is going to be
    // reset. We need to diff which items where added/removed and
    // update the content offset so it looks it is the same as before
    // reloading. This gives the perception of a smooth scroll.
    var offset: CGFloat = 0
    let diff = PagingDiff(from: oldVisibleItems, to: visibleItems)
    
    for indexPath in diff.removed() {
      offset += oldLayoutAttributes[indexPath]?.bounds.width ?? 0
      offset += options.menuItemSpacing
    }
    
    for indexPath in diff.added() {
      offset -= collectionViewLayout.layoutAttributes[indexPath]?.bounds.width ?? 0
      offset -= options.menuItemSpacing
    }
    
    collectionView.contentOffset = CGPoint(
      x: oldContentOffset.x - offset,
      y: oldContentOffset.y)
    
    // We need to perform layout here, if not the collection view
    // seems to get in a weird state.
    collectionView.layoutIfNeeded()
    
    // The content offset and distance between items can change while a
    // transition is in progress meaning the current transition will be
    // wrong. For instance, when hitting the edge of the collection view
    // while transitioning we need to reload all the paging items and
    // update the transition data.
    stateMachine.fire(.reload(contentOffset: collectionView.contentOffset))
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
    guard let currentPagingItem = state.currentPagingItem else { return options.estimatedItemWidth }

    if currentPagingItem == pagingItem {
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
    guard let collectionView = collectionView else { return }
    collectionView.setContentOffset(collectionView.contentOffset, animated: false)
  }

  // MARK: UICollectionViewDelegate
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let collectionViewLayout = collectionViewLayout else { return }
    
    // If we don't have any visible items there is no point in
    // checking if we're near an edge. This seems to be empty quite
    // often when scrolling very fast.
    if collectionView?.indexPathsForVisibleItems.isEmpty == true {
      return
    }
    
    if scrollView.near(edge: .left, clearance: collectionViewLayout.contentInsets.left) {
      if let firstPagingItem = visibleItems.items.first {
        if visibleItems.hasItemsBefore {
          reloadItems(around: firstPagingItem)
        }
      }
    } else if scrollView.near(edge: .right, clearance: collectionViewLayout.contentInsets.right) {
      if let lastPagingItem = visibleItems.items.last {
        if visibleItems.hasItemsAfter {
          reloadItems(around: lastPagingItem)
        }
      }
    }
  }
  
  open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let currentPagingItem = state.currentPagingItem else { return }
    
    let selectedPagingItem = visibleItems.pagingItem(for: indexPath)
    let direction = visibleItems.direction(from: currentPagingItem, to: selectedPagingItem)

    stateMachine.fire(.select(
      pagingItem: selectedPagingItem,
      direction: direction,
      animated: true))
  }
  
  // MARK: UICollectionViewDataSource
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagingCellReuseIdentifier, for: indexPath) as! PagingCell
    let pagingItem = visibleItems.items[indexPath.item]
    let selected = state.currentPagingItem == pagingItem
    cell.setPagingItem(pagingItem, selected: selected, theme: options.theme)
    return cell
  }
  
  open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return visibleItems.items.count
  }
  
  // MARK: EMPageViewControllerDataSource
  
  open func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    guard
      let dataSource = infiniteDataSource,
      let currentPagingItem = state.currentPagingItem,
      let pagingItem = dataSource.pagingViewController(self, pagingItemBeforePagingItem: currentPagingItem) else { return nil }
    
    return dataSource.pagingViewController(self, viewControllerForPagingItem: pagingItem)
  }
  
  open func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    guard
      let dataSource = infiniteDataSource,
      let currentPagingItem = state.currentPagingItem,
      let pagingItem = dataSource.pagingViewController(self, pagingItemAfterPagingItem: currentPagingItem) else { return nil }
    
    return dataSource.pagingViewController(self, viewControllerForPagingItem: pagingItem)
  }
  
  // MARK: EMPageViewControllerDelegate

  open func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {
    guard let currentPagingItem = state.currentPagingItem else { return }
    let oldState = state
    
    // EMPageViewController will trigger a scrolling event even if the
    // view has not appeared, causing the wrong initial paging item.
    if view.window != nil {
      stateMachine.fire(.scroll(progress: progress))
      
      if case .selected = oldState {
        if let upcomingPagingItem = state.upcomingPagingItem,
          let destinationViewController = destinationViewController {
          delegate?.pagingViewController(
            self,
            willScrollToItem: upcomingPagingItem,
            startingViewController: startingViewController,
            destinationViewController: destinationViewController)
        }
      } else {
        delegate?.pagingViewController(
          self,
          isScrollingFromItem: currentPagingItem,
          toItem: state.upcomingPagingItem,
          startingViewController: startingViewController,
          destinationViewController: destinationViewController,
          progress: progress)
      }
    }
  }
  
  open func em_pageViewController(_ pageViewController: EMPageViewController, willStartScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController) {
    return
  }
  
  open func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
    if transitionSuccessful {
      // If a transition finishes scrolling, but the upcoming paging
      // item is nil it means that the user scrolled away from one of
      // the items at the very edge. In this case, we don't want to
      // fire a .finishScrolling event as this will select the current
      // paging item, causing it to jump to that item even if it's
      // scrolled out of view. We still need to fire an event that
      // will reset the state to .selected.
      if state.upcomingPagingItem == nil {
        stateMachine.fire(.cancelScrolling)
      } else {
        stateMachine.fire(.finishScrolling)
      }
    }
    
    if let currentPagingItem = state.currentPagingItem {
      delegate?.pagingViewController(
        self,
        didScrollToItem: currentPagingItem,
        startingViewController: startingViewController,
        destinationViewController: destinationViewController,
        transitionSuccessful: transitionSuccessful)
    }
  }
  
  // MARK: PagingStateMachineDelegate
  
  func pagingStateMachine<U>(_ pagingStateMachine: PagingStateMachine<U>, transitionFromPagingItem currentPagingItem: U, toPagingItem upcomingPagingItem: U?) -> PagingTransition {
    guard
      let collectionView = collectionView,
      let collectionViewLayout = collectionViewLayout,
      let currentPagingItem = currentPagingItem as? T,
      let upcomingPagingItem = upcomingPagingItem as? T else {
      return PagingTransition(contentOffset: .zero, distance: 0)
    }
    
    // If the upcoming item is outside the currently visible
    // items we need to append the items that are around the
    // upcoming item so we can animate the transition.
    if visibleItems.itemsCache.contains(upcomingPagingItem) == false {
      reloadItems(around: upcomingPagingItem, keepExisting: true)
    }
    
    let distance = PagingDistance(
      view: collectionView,
      currentPagingItem: currentPagingItem,
      upcomingPagingItem: upcomingPagingItem,
      visibleItems: visibleItems,
      sizeCache: sizeCache,
      selectedScrollPosition: options.selectedScrollPosition,
      layoutAttributes: collectionViewLayout.layoutAttributes)
    
    return PagingTransition(
      contentOffset: collectionView.contentOffset,
      distance: distance.calculate())
  }
  
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
