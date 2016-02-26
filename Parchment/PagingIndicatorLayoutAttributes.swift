import UIKit

class PagingIndicatorLayoutAttributes: UICollectionViewLayoutAttributes {

  var backgroundColor: UIColor?
  
  func configure(options: PagingOptions) {
    if case let .Visible(height, index, _) = options.indicatorOptions {
      backgroundColor = options.theme.indicatorBackgroundColor
      frame.size.height = height
      frame.origin.y = options.headerHeight - height
      zIndex = index
    }
  }
  
  func update(from from: PagingIndicatorMetric, to: PagingIndicatorMetric, progress: CGFloat) {
    frame.origin.x = tween(from: from.x, to: to.x, progress: progress)
    frame.size.width = tween(from: from.width, to: to.width, progress: progress)
  }
  
}
