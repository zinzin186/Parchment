import Foundation

public protocol PagingViewControllerDelegate: class {
  func widthForPagingItem(pagingItem: PagingItem) -> CGFloat
}
