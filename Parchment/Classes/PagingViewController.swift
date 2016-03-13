import UIKit

public class PagingViewController: UIViewController {
  
  private let dataSource: PagingDataSource
  private let options: PagingOptions
  private let stateMachine: PagingStateMachine = PagingStateMachine()
  
  public init(viewControllers: [UIViewController], options: PagingOptions = DefaultPagingOptions()) {
    self.dataSource = PagingDataSource(viewControllers: viewControllers, options: options)
    self.options = options
    super.init(nibName: nil, bundle: nil)
  }

  required public init?(coder: NSCoder) {
    fatalError(InitCoderError)
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
    pagingContentViewController.setViewControllerForIndex(stateMachine.state.currentIndex,
      direction: stateMachine.directionForIndex(stateMachine.state.currentIndex),
      animated: false)
    
    stateMachine.stateObservers.append { [weak self] (stateMachine, oldState) in
      self?.handleStateUpdate(stateMachine.state)
    }
    
    stateMachine.eventObservers.append { [weak self] (stateMachine, event) in
      self?.handleEventUpdate(event)
    }
  }
  
  // MARK: Private
  
  private func handleEventUpdate(event: PagingEvent) {
    if case let .Select(index) = event {
      let direction = stateMachine.directionForIndex(index)
      pagingContentViewController.setViewControllerForIndex(index,
        direction: direction,
        animated: true)
    }
  }

  private func handleStateUpdate(state: PagingState) {
    
    collectionViewLayout.state = state
    pagingContentViewController.state = state
    
    switch state {
    case let .Current(index):
      let scrollPosition = options.selectedScrollPosition.collectionViewScrollPosition()
      let indexPath = NSIndexPath(forItem: index, inSection: 0)
      collectionView.selectItemAtIndexPath(indexPath,
        animated: true,
        scrollPosition: scrollPosition)
      
    case .Next, .Previous:
      let indexPath = NSIndexPath(forItem: state.visualSelectionIndex, inSection: 0)
      collectionViewLayout.invalidateLayout()
      collectionView.selectItemAtIndexPath(indexPath,
        animated: false,
        scrollPosition: .None)
    }
  }
  
  // MARK: Lazy Getters
  
  private lazy var collectionViewLayout: PagingCollectionViewLayout = {
    return PagingCollectionViewLayout(
      state: self.stateMachine.state,
      options: self.options)
  }()
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.collectionViewLayout)
    collectionView.register(PagingCell.self)
    collectionView.dataSource = self.dataSource
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.scrollEnabled = false
    return collectionView
  }()
  
  private lazy var pagingContentViewController: PagingContentViewController = {
    let pagingContentViewController = PagingContentViewController(
      dataSource: self.dataSource,
      state: self.stateMachine.state)
    pagingContentViewController.delegate = self
    return pagingContentViewController
  }()
  
}

extension PagingViewController: UICollectionViewDelegateFlowLayout {
  
  public func collectionView(collectionView: UICollectionView,
    didSelectItemAtIndexPath indexPath: NSIndexPath) {
    stateMachine.fire(.Select(index: indexPath.row))
  }
  
  public func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var width: CGFloat {
      switch options.cellSize {
      case let .SizeToFit(minWidth):
        return max(minWidth, collectionView.bounds.width / CGFloat(collectionView.numberOfItemsInSection(0)))
      case let .FixedWidth(width):
        return width
      }
    }
    return CGSize(width: width, height: options.headerHeight)
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
  
}

extension PagingViewController: PagingContentViewControllerDelegate {
  
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didChangeOffset offset: CGFloat) {
    stateMachine.fire(.Update(offset: offset))
  }
  
  func pagingContentViewController(pagingContentViewController: PagingContentViewController,
    didMoveToIndex index: Int) {
    stateMachine.fire(.DidMove(index: index))
  }
  
}
