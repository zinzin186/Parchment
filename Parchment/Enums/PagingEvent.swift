import Foundation

enum PagingEvent<T: PagingItem where T: Equatable> {
  case DidBeginDragging(upcomingPagingItem: T?, direction: PagingDirection)
  case Update(offset: CGFloat)
  case DidMove(pagingItem: T)
  case Select(pagingItem: T, direction: PagingDirection)
}
