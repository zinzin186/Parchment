import UIKit

class PagingIndicatorView: UICollectionReusableView {
  
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)
    if let attributes = layoutAttributes as? PagingIndicatorLayoutAttributes {
      backgroundColor = attributes.backgroundColor
    }
  }
  
}
