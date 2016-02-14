import UIKit
import Cartography

public class PagingViewController: UIViewController {
  
  private let dataSource: PagingDataSource
  private let options: PagingOptions
  private var pagingState: PagingState = .Current(0, .Forward) {
    didSet {
      handlePagingStateUpdate()
    }
  }
  
  public init(viewControllers: [UIViewController], options: PagingOptions = DefaultPagingOptions()) {
    self.dataSource = PagingDataSource(viewControllers: viewControllers, options: options)
    self.options = options
    super.init(nibName: nil, bundle: nil)
  }

  required public init?(coder: NSCoder) {
    fatalError(Error.InitCoder.rawValue)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    addViewController(pagingContentViewController)
    setupConstraints()
    pagingContentViewController.setViewControllerForIndex(pagingState.currentIndex,
      direction: .Forward,
      animated: false)
  }
  
  // MARK: Private
  
  private func setupConstraints() {
    constrain(view, collectionView, pagingContentViewController.view) { view, collectionView, pagingContentViewController in
      collectionView.height == options.headerHeight
      collectionView.left == view.left
      collectionView.right == view.right
      collectionView.top == view.top
      
      pagingContentViewController.top == collectionView.bottom
      pagingContentViewController.left == view.left
      pagingContentViewController.right == view.right
      pagingContentViewController.bottom == view.bottom
    }
  }
  
  private func handlePagingStateUpdate() {
    switch pagingState {
    case let .Current(index, _):
      let indexPath = NSIndexPath(forItem: index, inSection: 0)
      collectionView.selectItemAtIndexPath(indexPath,
        animated: true,
        scrollPosition: .CenteredHorizontally)
    default:
      collectionViewLayout.pagingState = pagingState
      collectionViewLayout.invalidateLayout()
    }
    pagingContentViewController.pagingState = pagingState
  }
  
  // MARK: Lazy Getters
  
  private lazy var collectionViewLayout: PagingCollectionViewLayout = {
    return PagingCollectionViewLayout(pagingState: self.pagingState, options: self.options)
  }()
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
    collectionView.register(PagingCell.self)
    collectionView.dataSource = self.dataSource
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.whiteColor()
    return collectionView
  }()
  
  private lazy var pagingContentViewController: PagingContentViewController = {
    let pagingContentViewController = PagingContentViewController(dataSource: self.dataSource, pagingState: self.pagingState)
    pagingContentViewController.delegate = self
    return pagingContentViewController
  }()
  
}

extension PagingViewController: UICollectionViewDelegateFlowLayout {
  
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let direction = pagingState.directionForUpcomingIndex(indexPath.row)
    pagingContentViewController.setViewControllerForIndex(indexPath.row, direction: direction, animated: true)
  }
  
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
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
  
}

extension PagingViewController: PagingContentViewControllerDelegate {
  
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didChangeOffset offset: CGFloat, towardsIndex upcomingIndex: Int) {
    if upcomingIndex > pagingState.currentIndex {
      self.pagingState = .Next(pagingState.currentIndex, upcomingIndex, offset)
    } else if upcomingIndex < pagingState.currentIndex {
      self.pagingState = .Previous(pagingState.currentIndex, upcomingIndex, fabs(offset))
    }
  }
  
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didMoveToIndex index: Int) {
    pagingState = .Current(index, pagingState.directionForUpcomingIndex(index))
  }
  
}
