import Foundation

enum PagingState<T: PagingItem where T: Equatable>: Equatable, CustomStringConvertible {
  
  case Previous(pagingItem: T, upcomingPagingItem: T?, offset: CGFloat)
  case Current(pagingItem: T)
  case Next(pagingItem: T, upcomingPagingItem: T?, offset: CGFloat)
  
  var description: String {
    switch self {
    case let .Previous(_, _, offset):
      return "PagingState: .Previous(offset: \(offset)"
    case let .Next(_, _, offset):
      return "PagingState: .Next(offset: \(offset)"
    case .Current:
      return "PagingState: .Current"
    }
  }
  
}

extension PagingState {
  
  var offset: CGFloat {
    switch self {
    case let .Previous(_, _, offset):
      return offset
    case let .Next(_, _, offset):
      return offset
    case .Current:
      return 0
    }
  }
  
  var currentPagingItem: T {
    switch self {
    case let .Previous(pagingItem, _, _):
      return pagingItem
    case let .Next(pagingItem, _, _):
      return pagingItem
    case let .Current(pagingItem):
      return pagingItem
    }
  }
  
  var upcomingPagingItem: T? {
    switch self {
    case let .Previous(_, upcomingPagingItem, _):
      return upcomingPagingItem
    case let .Next(_, upcomingPagingItem, _):
      return upcomingPagingItem
    case .Current:
      return nil
    }
  }
  
  var visualSelectionPagingItem: T {
    if fabs(offset) > 0.5 {
      return upcomingPagingItem ?? currentPagingItem
    } else {
      return currentPagingItem
    }
  }
  
}

func ==<T: PagingItem where T: Equatable>(lhs: PagingState<T>, rhs: PagingState<T>) -> Bool {
  switch (lhs, rhs) {
  case (let .Previous(x, y, z), let .Previous(a, b, c)):
    if x == a && z == c {
      if let y = y, b = b where y == b {
        return true
      } else if y == nil && b == nil {
        return true
      }
    }
    return false
  case (let .Next(x, y, z), let .Next(a, b, c)):
    if x == a && z == c {
      if let y = y, b = b where y == b {
        return true
      } else if y == nil && b == nil {
        return true
      }
    }
    return false
  case (let .Current(x), let .Current(a)) where x == a:
    return true
  default:
    return false
  }
}
