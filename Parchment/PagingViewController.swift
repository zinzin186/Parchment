import UIKit
import Cartography

public class PagingViewController: UIViewController {
  
  private let dataSource: PagingDataSource
  private var pagingState: PagingState = .Current(0, PagingDirection.Forward) {
    didSet {
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
  }
  
  public init(viewControllers: [UIViewController]) {
    self.dataSource = PagingDataSource(viewControllers: viewControllers)
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
      collectionView.height == 50
      collectionView.left == view.left
      collectionView.right == view.right
      collectionView.top == view.top + 20
      
      pagingContentViewController.top == collectionView.bottom
      pagingContentViewController.left == view.left
      pagingContentViewController.right == view.right
      pagingContentViewController.bottom == view.bottom
    }
  }
  
  
  
  // MARK: Lazy Getters
  
  private lazy var collectionViewLayout: PagingCollectionViewLayout = {
    return PagingCollectionViewLayout(pagingState: self.pagingState)
  }()
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
    collectionView.register(PagingCell.self)
    collectionView.dataSource = self.dataSource
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.greenColor()
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
    if indexPath.row % 2 == 0 {
      return CGSize(width: 100, height: 50)
    } else {
      return CGSize(width: 150, height: 50)
    }
  }
  
}

extension PagingViewController: PagingContentViewControllerDelegate {
  
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didChangeOffset offset: CGFloat, towardsIndex upcomingIndex: Int) {
    let currentIndex = self.pagingState.currentIndex
    if upcomingIndex > currentIndex {
      self.pagingState = .Next(currentIndex, upcomingIndex, offset)
    } else if upcomingIndex < currentIndex {
      self.pagingState = .Previous(currentIndex, upcomingIndex, fabs(offset))
    }
  }
  
  func pagingContentViewController(pagingContentViewController: PagingContentViewController, didMoveToIndex index: Int) {
    pagingState = .Current(index, self.pagingState.directionForUpcomingIndex(index))
  }
  
}
