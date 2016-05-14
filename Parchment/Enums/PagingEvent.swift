import Foundation

enum PagingEvent<T: PagingItem where T: Equatable> {
  case Scroll(offset: CGFloat)
  case Select(pagingItem: T, direction: PagingDirection)
  case FinishScrolling
}
