import UIKit

public enum PagingMenuItemSize {
  case Fixed(width: CGFloat, height: CGFloat)
  case SizeToFit(minWidth: CGFloat, height: CGFloat)

  public var width: CGFloat {
    switch self {
    case let .Fixed(width, _): return width
    case let .SizeToFit(minWidth, _): return minWidth
    }
  }
  
  public var height: CGFloat {
    switch self {
    case let .Fixed(_, height): return height
    case let .SizeToFit(_, height): return height
    }
  }
}

public enum PagingIndicatorOptions {
  case Hidden
  case Visible(
    height: CGFloat,
    zIndex: Int,
    insets: UIEdgeInsets)
}

public enum PagingBorderOptions {
  case Hidden
  case Visible(
    height: CGFloat,
    zIndex: Int,
    insets: UIEdgeInsets)
}

public enum PagingSelectedScrollPosition {
  case Left
  case Right
  case AlwaysCentered
  case PreferCentered
}

public protocol PagingTheme {
  var font: UIFont { get }
  var textColor: UIColor { get }
  var selectedTextColor: UIColor { get }
  var backgroundColor: UIColor { get }
  var headerBackgroundColor: UIColor { get }
  var borderColor: UIColor { get }
  var indicatorColor: UIColor { get }
}

public protocol PagingOptions {
  var theme: PagingTheme { get }
  var borderOptions: PagingBorderOptions { get }
  var indicatorOptions: PagingIndicatorOptions { get }
  var selectedScrollPosition: PagingSelectedScrollPosition { get }
  var menuItemSize: PagingMenuItemSize { get }
  var menuItemClass: PagingCell.Type { get }
}

extension PagingOptions {
  
  var scrollPosition: UICollectionViewScrollPosition {
    switch selectedScrollPosition {
    case .Left:
      return .Left
    case .Right:
      return .Right
    case .AlwaysCentered, .PreferCentered:
      return .CenteredHorizontally
    }
  }
  
}
