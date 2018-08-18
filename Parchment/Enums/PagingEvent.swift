import Foundation

enum PagingEvent {
  case scroll(progress: CGFloat)
  case initial(pagingItem: PagingItem)
  case select(pagingItem: PagingItem, direction: PagingDirection, animated: Bool)
  case finishScrolling
  case transitionSize
  case cancelScrolling
  case reload(contentOffset: CGPoint)
  case removeAll
  case reset(pagingItem: PagingItem)
}

extension PagingEvent {
  
  var animated: Bool? {
    switch self {
    case let .select(_, _, animated):
      return animated
    default:
      return nil
    }
  }
  
}
