import Foundation

enum PagingEvent<T: PagingItem where T: Equatable> {
  case Scroll(offset: CGFloat)
  case Select(pagingItem: T, direction: PagingDirection, animated: Bool)
  case FinishScrolling
}

extension PagingEvent {
  
  var animated: Bool? {
    switch self {
    case let .Select(_, _, animated):
      return animated
    default:
      return nil
    }
  }
  
}