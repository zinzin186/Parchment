import Foundation

enum PagingState: Equatable {
  case Previous(index: Int, upcomingIndex: Int, offset: CGFloat)
  case Current(index: Int)
  case Next(index: Int, upcomingIndex: Int, offset: CGFloat)
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
    case let .Current(index):
      return index
    }
  }
  
  var upcomingIndex: Int {
    switch self {
    case let .Previous(_, upcomingIndex, _):
      return upcomingIndex
    case let .Next(_, upcomingIndex, _):
      return upcomingIndex
    case let .Current(index):
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
      return targetIndex
    } else {
      return currentIndex
    }
  }
  
}

func ==(lhs: PagingState, rhs: PagingState) -> Bool {
  switch (lhs, rhs) {
  case (let .Previous(x, y, z), let .Previous(a, b, c)) where x == a && y == b && z == c:
    return true
  case (let .Next(x, y, z), let .Next(a, b, c)) where x == a && y == b && z == c:
    return true
  case (let .Current(x), let .Current(a)) where x == a:
    return true
  default:
    return false
  }
}
