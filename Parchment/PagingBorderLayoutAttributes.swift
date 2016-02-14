import UIKit

class PagingBorderLayoutAttributes: UICollectionViewLayoutAttributes {
  
  var backgroundColor: UIColor?
  var insets: UIEdgeInsets = UIEdgeInsets()
  
  func configure(options: PagingOptions) {
    switch options.borderOptions {
    case let .Visible(height, borderInsets):
      insets = borderInsets
      backgroundColor = options.theme.borderBackgroundColor
      frame.origin.x = insets.left
      frame.origin.y = options.headerHeight - height
      frame.size.height = height
      zIndex = Int.max - 1
      alpha = 1
    case .Hidden:
      alpha = 0
    }
  }
  
  func update(width width: CGFloat) {
    frame.size.width = width - insets.left - insets.right
  }
  
}
