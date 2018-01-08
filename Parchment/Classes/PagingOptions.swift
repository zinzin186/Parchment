import UIKit

public class PagingOptions {
  public var menuItemSize: PagingMenuItemSize
  public var menuItemClass: PagingCell.Type
  public var menuItemSpacing: CGFloat
  public var menuInsets: UIEdgeInsets
  public var menuHorizontalAlignment: PagingMenuHorizontalAlignment
  public var menuTransition: PagingMenuTransition
  public var menuInteraction: PagingMenuInteraction
  public var selectedScrollPosition: PagingSelectedScrollPosition
  public var indicatorOptions: PagingIndicatorOptions
  public var indicatorClass: PagingIndicatorView.Type
  public var borderOptions: PagingBorderOptions
  public var borderClass: PagingBorderView.Type
  public var theme: PagingTheme
  public var includeSafeAreaInsets: Bool
  
  public var scrollPosition: UICollectionViewScrollPosition {
    switch selectedScrollPosition {
    case .left:
      return .left
    case .right:
      return .right
    case .preferCentered, .center:
      return .centeredHorizontally
    }
  }
  
  public var menuHeight: CGFloat {
    return menuItemSize.height + menuInsets.top + menuInsets.bottom
  }
  
  public var estimatedItemWidth: CGFloat {
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
