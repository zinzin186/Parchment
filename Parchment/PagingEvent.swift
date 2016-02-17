import Foundation

enum PagingEvent {
  case UpdateOffset(CGFloat)
  case WillMove(Int)
  case DidMove(Int)
  case Select(Int, PagingDirection)
}
