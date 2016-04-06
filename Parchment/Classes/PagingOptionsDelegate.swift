import UIKit

class PagingOptionsDelegate: PagingViewControllerDelegate {
  
  let collectionView: UICollectionView
  let options: PagingOptions
  
  init(options: PagingOptions, collectionView: UICollectionView) {
    self.options = options
    self.collectionView = collectionView
  }
  
  func widthForPagingItem(pagingItem: PagingItem) -> CGFloat {
    switch options.menuItemSize {
    case let .SizeToFit(minWidth, _):
      return max(minWidth, collectionView.bounds.width / CGFloat(collectionView.numberOfItemsInSection(0)))
    case let .Fixed(width, _):
      return width
    case .Dynamic:
      return 0
    }
  }
  
}
