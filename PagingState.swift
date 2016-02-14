import Foundation

enum PagingState {
  
  case Previous(Int, Int, CGFloat)
  case Current(Int, PagingDirection)
  case Next(Int, Int, CGFloat)
  
  var offset: CGFloat {
    switch self {
    case let .Previous(_, _, offset):
      return offset
    case let .Next(_, _,offset):
      return offset
    case .Current:
      return 0
    }
  }
  
  var currentIndex: Int {
    switch self {
    case let .Previous(index, _, _):
      return index
    case let .Next(index, _, _):
      return index
    case let .Current(index, _):
      return index
    }
  }
  
  var upcomingIndex: Int? {
    switch self {
    case let .Previous(_, index, _):
      return index
    case let .Next(_, index, _):
      return index
    case .Current:
      return nil
    }
  }
  
  func directionForUpcomingIndex(index: Int) -> PagingDirection {
    if self.currentIndex > index {
      return .Reverse
    } else {
      return .Forward
    }
  }
  
}
