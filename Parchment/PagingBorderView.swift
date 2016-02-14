import UIKit

class PagingBorderView: UICollectionReusableView {
  
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)
    if let attributes = layoutAttributes as? PagingBorderLayoutAttributes {
      backgroundColor = attributes.backgroundColor
    }
  }
  
}
