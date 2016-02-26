import UIKit

public enum PagingCellSize {
  case FixedWidth(width: CGFloat)
  case SizeToFit(minWidth: CGFloat)
}

public enum PagingIndicatorOptions {
  case Hidden
  case Visible(height: CGFloat, zIndex: Int, insets: UIEdgeInsets)
}

public enum PagingBorderOptions {
  case Hidden
  case Visible(height: CGFloat, zIndex: Int, insets: UIEdgeInsets)
}

public protocol PagingTheme {
  var font: UIFont { get }
  var textColor: UIColor { get }
  var selectedTextColor: UIColor { get }
  var headerBackgroundColor: UIColor { get }
  var indicatorBackgroundColor: UIColor { get }
  var borderBackgroundColor: UIColor { get }
}

public protocol PagingOptions {
  var headerHeight: CGFloat { get }
  var selectedScrollPosition: UICollectionViewScrollPosition { get }
  var cellSize: PagingCellSize { get }
  var theme: PagingTheme { get }
  var borderOptions: PagingBorderOptions { get }
  var indicatorOptions: PagingIndicatorOptions { get }
}
