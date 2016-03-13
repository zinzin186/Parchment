import UIKit
import Cartography

class PagingView: UIView {
  
  private let pagingContentView: UIView
  private let collectionView: UICollectionView
  private let options: PagingOptions
  
  init(pagingContentView: UIView, collectionView: UICollectionView, options: PagingOptions) {
    
    self.pagingContentView = pagingContentView
    self.collectionView = collectionView
    self.options = options
    
    super.init(frame: .zero)
    
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError(InitCoderError)
  }
  
  private func configure() {
    
    addSubview(collectionView)
    addSubview(pagingContentView)
    
    constrain(self, collectionView, pagingContentView) { view, collectionView, pagingContentView in
      collectionView.height == options.headerHeight
      collectionView.left == view.left
      collectionView.right == view.right
      collectionView.top == view.top
      
      pagingContentView.top == collectionView.bottom
      pagingContentView.left == view.left
      pagingContentView.right == view.right
      pagingContentView.bottom == view.bottom
    }
  }
  
}
