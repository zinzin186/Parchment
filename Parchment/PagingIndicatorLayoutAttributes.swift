import UIKit

struct PagingIndicatorMetric {
  let frame: CGRect
  let insets: UIEdgeInsets
}

class PagingIndicatorLayoutAttributes: UICollectionViewLayoutAttributes {

  var backgroundColor: UIColor?
  
  func configure(options: PagingOptions) {
    switch options.indicatorOptions {
    case let .Visible(height, _):
      backgroundColor = options.theme.indicatorBackgroundColor
      zIndex = Int.max
      frame.size.height = height
      frame.origin.y = options.headerHeight - height
      alpha = 1
    case .Hidden:
      alpha = 0
    }
  }
  
  func update(from from: PagingIndicatorMetric, to: PagingIndicatorMetric, progress: CGFloat) {
    
    frame.origin.x = tween(
      from: from.frame.origin.x + from.insets.left,
      to: to.frame.origin.x + to.insets.left,
      progress: progress)
    
    frame.size.width = tween(
      from: from.frame.width - from.insets.right - from.insets.left,
      to: to.frame.width - to.insets.right - to.insets.left,
      progress: progress)
  }

  
}
