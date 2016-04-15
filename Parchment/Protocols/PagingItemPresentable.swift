import Foundation

protocol PagingItemPresentable {
  func widthForPagingItem<T: PagingItem>(pagingItem: T) -> CGFloat
}
