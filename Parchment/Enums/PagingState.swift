import Foundation

enum PagingState<T: PagingItem>: Equatable where T: Equatable {
  case selected(pagingItem: T)
  case scrolling(pagingItem: T, upcomingPagingItem: T?, progress: CGFloat)
}

extension PagingState {
  
  var currentPagingItem: T {
    switch self {
    case let .scrolling(pagingItem, _, _):
      return pagingItem
    case let .selected(pagingItem):
      return pagingItem
    }
  }
  
  var upcomingPagingItem: T? {
    switch self {
    case let .scrolling(_, upcomingPagingItem, _):
      return upcomingPagingItem
    case .selected:
      return nil
    }
  }
  
  var progress: CGFloat {
    switch self {
    case let .scrolling(_, _, progress):
      return progress
    case .selected:
      return 0
    }
  }
  
  var visuallySelectedPagingItem: T {
    if fabs(progress) > 0.5 {
      return upcomingPagingItem ?? currentPagingItem
    } else {
      return currentPagingItem
    }
  }
  
}

func ==<T: PagingItem>(lhs: PagingState<T>, rhs: PagingState<T>) -> Bool where T: Equatable {
  switch (lhs, rhs) {
  case (let .scrolling(a, b, c), let .scrolling(x, y, z)):
    if a == x && c == z {
      if let b = b, let y = y, b == y {
        return true
      } else if b == nil && y == nil {
        return true
      }
    }
    return false
  case (let .selected(a), let .selected(b)) where a == b:
    return true
  default:
    return false
  }
}
