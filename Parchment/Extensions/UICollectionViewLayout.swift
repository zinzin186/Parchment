import UIKit

extension UICollectionViewLayout {
  
  var collection: UICollectionView {
    guard let collectionView = self.collectionView else {
      fatalError("collection view layout is missing collection view")
    }
    return collectionView
  }
  
  func register<T: UICollectionReusableView where T: ReusableView>(_: T.Type) {
    registerClass(T.self, forDecorationViewOfKind: T.defaultReuseIdentifier)
  }
  
  func copyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    guard let layoutAttributes = layoutAttributes.copy() as? UICollectionViewLayoutAttributes else {
      fatalError("failed to copy layout attributes")
    }
    return layoutAttributes
  }
  
}
