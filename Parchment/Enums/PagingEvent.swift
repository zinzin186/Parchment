import Foundation

enum PagingEvent {
  case Update(offset: CGFloat)
  case DidMove(index: Int)
  case Select(index: Int)
}
