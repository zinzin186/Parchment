import UIKit

class PagingIndicator: UICollectionReusableView {
  
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)
    if let attributes = layoutAttributes as? PagingIndicatorLayoutAttributes {
      backgroundColor = attributes.backgroundColor
    }
  }
  
}
