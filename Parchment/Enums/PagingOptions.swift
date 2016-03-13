import UIKit

public enum PagingCellSize {
  case FixedWidth(width: CGFloat)
  case SizeToFit(minWidth: CGFloat)
}

public enum PagingIndicator {
  case Hidden
  case Visible(height: CGFloat, zIndex: Int, insets: UIEdgeInsets)
}

public enum PagingBorder {
  case Hidden
  case Visible(height: CGFloat, zIndex: Int, insets: UIEdgeInsets)
}

public enum PagingSelectedScrollPosition {
  case Left
  case Right
  case AlwaysCentered
  case PreferCentered
  
  public func collectionViewScrollPosition() -> UICollectionViewScrollPosition {
    switch self {
    case .Left:
      return .Left
    case .Right:
      return .Right
    case .AlwaysCentered, .PreferCentered:
      return .CenteredHorizontally
    }
  }
}

public protocol PagingTheme {
  var font: UIFont { get }
  var textColor: UIColor { get }
  var selectedTextColor: UIColor { get }
  var backgroundColor: UIColor { get }
  var headerBackgroundColor: UIColor { get }
  var indicatorBackgroundColor: UIColor { get }
  var borderBackgroundColor: UIColor { get }
}

public protocol PagingOptions {
  var headerHeight: CGFloat { get }
  var selectedScrollPosition: PagingSelectedScrollPosition { get }
  var cellSize: PagingCellSize { get }
  var theme: PagingTheme { get }
  var borderOptions: PagingBorder { get }
  var indicatorOptions: PagingIndicator { get }
}
