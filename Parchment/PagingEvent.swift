import Foundation

enum PagingEvent {
  case Update(offset: CGFloat)
  case WillMove(index: Int)
  case DidMove(index: Int)
  case Select(index: Int, direction: PagingDirection)
}
