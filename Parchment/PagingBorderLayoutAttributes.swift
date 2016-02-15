import UIKit

class PagingBorderLayoutAttributes: UICollectionViewLayoutAttributes {
  
  var backgroundColor: UIColor?
  var insets: UIEdgeInsets = UIEdgeInsets()
  
  func configure(options: PagingOptions) {
    if case let .Visible(height, borderInsets) = options.borderOptions {
      insets = borderInsets
      backgroundColor = options.theme.borderBackgroundColor
      frame.origin.x = insets.left
      frame.origin.y = options.headerHeight - height
      frame.size.height = height
      zIndex = Int.max - 1
    }
  }
  
  func update(width width: CGFloat) {
    frame.size.width = width - insets.left - insets.right
  }
  
}
