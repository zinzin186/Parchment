import UIKit

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
      insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
      backgroundColor: UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1))
  }
  
  var borderOptions: PagingBorderOptions {
    return .Visible(
      height: 1,
      zIndex: Int.max - 1,
      insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
      backgroundColor: UIColor(white: 0.9, alpha: 1))
  }
  
  var menuItemClass: PagingCell.Type {
    return DefaultPagingCell.self
  }

}

struct DefaultPagingTheme: PagingTheme {}
struct DefaultPagingOptions: PagingOptions {}
