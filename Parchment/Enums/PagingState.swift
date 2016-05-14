import Foundation

enum PagingState<T: PagingItem where T: Equatable>: Equatable {
  case Selected(pagingItem: T)
  case Scrolling(pagingItem: T, upcomingPagingItem: T?, offset: CGFloat)
}

extension PagingState {
  
  var currentPagingItem: T {
    switch self {
    case let .Scrolling(pagingItem, _, _):
      return pagingItem
    case let .Selected(pagingItem):
      return pagingItem
    }
  }
  
  var upcomingPagingItem: T? {
    switch self {
    case let .Scrolling(_, upcomingPagingItem, _):
      return upcomingPagingItem
    case .Selected:
      return nil
    }
  }
  
  var offset: CGFloat {
    switch self {
    case let .Scrolling(_, _, offset):
      return offset
    case .Selected:
      return 0
    }
  }
  
  var visuallySelectedPagingItem: T {
    if fabs(offset) > 0.5 {
      return upcomingPagingItem ?? currentPagingItem
    } else {
      return currentPagingItem
    }
  }
  
}

func ==<T: PagingItem where T: Equatable>(lhs: PagingState<T>, rhs: PagingState<T>) -> Bool {
  switch (lhs, rhs) {
  case (let .Scrolling(a, b, c), let .Scrolling(x, y, z)):
    if a == x && c == z {
      if let b = b, y = y where b == y {
        return true
      } else if b == nil && y == nil {
        return true
      }
    }
    return false
  case (let .Selected(a), let .Selected(b)) where a == b:
    return true
  default:
    return false
  }
}
