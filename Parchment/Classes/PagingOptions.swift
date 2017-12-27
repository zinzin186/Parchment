import UIKit

open class PagingOptions {
  var menuItemSize: PagingMenuItemSize
  var menuItemClass: PagingCell.Type
  var menuItemSpacing: CGFloat
  var menuInsets: UIEdgeInsets
  var menuHorizontalAlignment: PagingMenuHorizontalAlignment
  var menuTransition: PagingMenuTransition
  var menuInteraction: PagingMenuInteraction
  var selectedScrollPosition: PagingSelectedScrollPosition
  var indicatorOptions: PagingIndicatorOptions
  var indicatorClass: PagingIndicatorView.Type
  var borderOptions: PagingBorderOptions
  var borderClass: PagingBorderView.Type
  var theme: PagingTheme
  var includeSafeAreaInsets: Bool
  
  var scrollPosition: UICollectionViewScrollPosition {
    switch selectedScrollPosition {
    case .left:
      return .left
    case .right:
      return .right
    case .preferCentered:
      return .centeredHorizontally
    }
  }
  
  var menuHeight: CGFloat {
    return menuItemSize.height + menuInsets.top + menuInsets.bottom
  }
  
  var estimatedItemWidth: CGFloat {
    switch menuItemSize {
    case let .fixed(width, _):
      return width
    case let .sizeToFit(minWidth, _):
      return minWidth
    }
  }
  
  public init() {
    theme = PagingTheme()
    selectedScrollPosition = .preferCentered
    menuItemSize = .sizeToFit(minWidth: 150, height: 40)
    menuTransition = .scrollAlongside
    menuInteraction = .scrolling
    menuItemClass = PagingTitleCell.self
    menuInsets = UIEdgeInsets.zero
    menuItemSpacing = 0
    menuHorizontalAlignment = .left
    includeSafeAreaInsets = true
    indicatorClass = PagingIndicatorView.self
    borderClass = PagingBorderView.self
    
    indicatorOptions = .visible(
        height: 4,
        zIndex: Int.max,
        spacing: UIEdgeInsets.zero,
        insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
  
    borderOptions = .visible(
        height: 1,
        zIndex: Int.max - 1,
        insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
  }
}
