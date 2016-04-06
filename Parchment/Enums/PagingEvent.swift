import Foundation

enum PagingEvent<T: PagingItem where T: Equatable> {
  case Update(offset: CGFloat)
  case Select(pagingItem: T, direction: PagingDirection)
  case Reload(pagingItem: T, size: CGSize)
  case DidMove(pagingItem: T)
  case DidBeginDragging(upcomingPagingItem: T?, direction: PagingDirection)
}
