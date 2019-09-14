import UIKit

open class PagingMenuView: UIView {
  
  public weak var delegate: PagingMenuDelegate? {
    didSet {
      pagingController.delegate = delegate
    }
  }
  
  public weak var dataSource: PagingMenuDataSource? {
    didSet {
      pagingController.dataSource = dataSource
    }
  }
  
  /// The current state of the menu items. Indicates whether an item
  /// is currently selected or is scrolling to another item. Can be
  /// used to get the distance and progress of any ongoing transition.
  public var state: PagingState {
    return pagingController.state
  }
  
  /// The `PagingItem`'s that are currently visible in the collection
  /// view. The items in this array are not necessarily the same as
  /// the `visibleCells` property on `UICollectionView`.
  public var visibleItems: PagingItems {
    return pagingController.visibleItems
  }
  
  /// A custom collection view layout that lays out all the menu items
  /// horizontally. You can customize the behavior of the layout by
  /// setting the customization properties on `PagingViewController`.
  /// You can also use your own subclass of the layout by defining the
  /// `menuLayoutClass` property.
  public private(set) lazy var collectionViewLayout: PagingCollectionViewLayout = {
    return createLayout(layout: options.menuLayoutClass.self)
  }()
  
  /// Used to display the menu items that scrolls along with the
  /// content. Using a collection view means you can create custom
  /// cells that display pretty much anything. By default, scrolling
  /// is enabled in the collection view.
  public lazy var collectionView: UICollectionView = {
    return UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
  }()
  
  /// An instance that stores all the customization so that it's
  /// easier to share between other classes.
  public var options = PagingOptions() {
    didSet {
      if options.menuLayoutClass != oldValue.menuLayoutClass {
        let layout = createLayout(layout: options.menuLayoutClass.self)
        collectionViewLayout = layout
        collectionViewLayout.options = options
        collectionView.setCollectionViewLayout(layout, animated: false)
      }
      else {
        collectionViewLayout.options = options
      }
      
      pagingController.options = options
    }
  }
  
  // MARK: Private Properties
  
  private lazy var pagingController = PagingController(options: options)
  
  // MARK: Initializers
  
  /// Creates an instance of `PagingViewController`. You need to call
  /// `select(pagingItem:animated:)` in order to set the initial view
  /// controller before any items become visible.
  public override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  // TODO: Figure out how we can remove this method.
  open func viewAppeared() {
    pagingController.viewAppeared()
  }
  
  open func transitionSize() {
    pagingController.transitionSize()
  }
  
  open func contentScrolled(progress: CGFloat) {
    pagingController.contentScrolled(progress: progress)
  }
  
  open func contentFinishedScrolling() {
    pagingController.contentFinishedScrolling()
  }
  
  /// Reload data around given paging item. This will set the given
  /// paging item as selected and generate new items around it.
  ///
  /// - Parameter pagingItem: The `PagingItem` that will be selected
  /// after the data reloads.
  open func reload(around pagingItem: PagingItem) {
    pagingController.reloadMenu(around: pagingItem)
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
  open func select(pagingItem: PagingItem, animated: Bool = false) {
    pagingController.select(pagingItem: pagingItem, animated: animated)
  }
  
  // MARK: Private Methods
  
  private func configure() {
    collectionView.backgroundColor = options.menuBackgroundColor
    collectionView.delegate = self
    addSubview(collectionView)
    constrainToEdges(collectionView)
    
    pagingController.collectionView = collectionView
    pagingController.collectionViewLayout = collectionViewLayout
  }
  
}

extension PagingMenuView: UICollectionViewDelegate {
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    pagingController.menuScrolled()
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    pagingController.select(indexPath: indexPath, animated: true)
  }
  
}
