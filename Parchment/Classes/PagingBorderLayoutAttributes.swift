import UIKit

class PagingBorderLayoutAttributes: UICollectionViewLayoutAttributes {
  
  var backgroundColor: UIColor?
  var insets: UIEdgeInsets = UIEdgeInsets()
  
  func configure(options: PagingOptions) {
    if case let .Visible(height, index, borderInsets) = options.borderOptions {
      insets = borderInsets
      backgroundColor = options.theme.borderColor
      frame.origin.x = insets.left
      frame.origin.y = options.menuItemSize.height - height
      frame.size.height = height
      zIndex = index
    }
  }
  
  func update(width width: CGFloat) {
    frame.size.width = width - insets.left - insets.right
  }
  
}
