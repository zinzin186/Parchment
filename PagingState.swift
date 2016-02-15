import Foundation

enum PagingState {
  case Previous(Int, Int, CGFloat)
  case Current(Int, PagingDirection)
  case Next(Int, Int, CGFloat)
}

extension PagingState {
  
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
  
  var upcomingIndex: Int {
    switch self {
    case let .Previous(_, upcomingIndex, _):
      return upcomingIndex
    case let .Next(_, upcomingIndex, _):
      return upcomingIndex
    case let .Current(index, _):
      return index
    }
  }
  
  var targetIndex: Int {
    switch self {
    case .Previous:
      return upcomingIndex != currentIndex ? upcomingIndex : currentIndex - 1
    case .Next:
      return upcomingIndex != currentIndex ? upcomingIndex : currentIndex + 1
    case .Current:
      return currentIndex
    }
  }
  
  var visualSelectionIndex: Int {
    if fabs(offset) > 0.5 {
      return targetIndex ?? currentIndex
    } else {
      return currentIndex
    }
  }
  
}
