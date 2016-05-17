import UIKit

public enum PagingMenuItemSize {
  case Fixed(width: CGFloat, height: CGFloat)
  case SizeToFit(minWidth: CGFloat, height: CGFloat)
}

public extension PagingMenuItemSize {
  
  var width: CGFloat {
    switch self {
    case let .Fixed(width, _): return width
    case let .SizeToFit(minWidth, _): return minWidth
    }
  }
  
  var height: CGFloat {
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
  var menuItemSize: PagingMenuItemSize { get }
  var menuItemClass: PagingCell.Type { get }
  var menuItemSpacing: CGFloat { get }
  var menuInsets: UIEdgeInsets { get }
  var selectedScrollPosition: PagingSelectedScrollPosition { get }
  var indicatorOptions: PagingIndicatorOptions { get }
  var borderOptions: PagingBorderOptions { get }
  var theme: PagingTheme { get }
}

extension PagingOptions {
  
  var scrollPosition: UICollectionViewScrollPosition {
    switch selectedScrollPosition {
    case .Left:
      return .Left
    case .Right:
      return .Right
    case .PreferCentered:
      return .CenteredHorizontally
    }
  }
  
  var menuHeight: CGFloat {
    return menuItemSize.height + menuInsets.top + menuInsets.bottom
  }
  
}

public extension PagingTheme {
  
  var font: UIFont {
    return UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
  }
  
  var textColor: UIColor {
    return UIColor.blackColor()
  }
  
  var selectedTextColor: UIColor {
    return UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
  }
  
  var backgroundColor: UIColor {
    return UIColor.whiteColor()
  }
  
  var headerBackgroundColor: UIColor {
    return UIColor.whiteColor()
  }
  
  var indicatorColor: UIColor {
    return UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
  }
  
  var borderColor: UIColor {
    return UIColor(white: 0.9, alpha: 1)
  }
  
}

public extension PagingOptions {
  
  var menuItemSize: PagingMenuItemSize {
    return .SizeToFit(minWidth: 150, height: 40)
  }
  
  var selectedScrollPosition: PagingSelectedScrollPosition {
    return .PreferCentered
  }
  
  var theme: PagingTheme {
    return DefaultPagingTheme()
  }
  
  var indicatorOptions: PagingIndicatorOptions {
    return .Visible(
      height: 4,
      zIndex: Int.max,
      insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
  }
  
  var borderOptions: PagingBorderOptions {
    return .Visible(
      height: 1,
      zIndex: Int.max - 1,
      insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
  }
  
  var menuItemClass: PagingCell.Type {
    return PagingTitleCell.self
  }
  
  var menuInsets: UIEdgeInsets {
    return UIEdgeInsets()
  }
  
  var menuItemSpacing: CGFloat {
    return 0
  }
  
}

struct DefaultPagingTheme: PagingTheme {}
struct DefaultPagingOptions: PagingOptions {}
