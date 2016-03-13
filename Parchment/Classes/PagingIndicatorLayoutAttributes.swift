import UIKit

class PagingIndicatorLayoutAttributes: UICollectionViewLayoutAttributes {

  var backgroundColor: UIColor?
  
  func configure(options: PagingOptions) {
    if case let .Visible(height, index, _, color) = options.indicatorOptions {
      backgroundColor = color
      frame.size.height = height
      frame.origin.y = options.menuItemSize.height - height
      zIndex = index
    }
  }
  
  func update(from from: PagingIndicatorMetric, to: PagingIndicatorMetric, progress: CGFloat) {
    frame.origin.x = tween(from: from.x, to: to.x, progress: progress)
    frame.size.width = tween(from: from.width, to: to.width, progress: progress)
  }
  
}
