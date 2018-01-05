import Foundation

enum PagingState<T: PagingItem>: Equatable where T: Equatable {
  case selected(pagingItem: T)
  case scrolling(
    pagingItem: T,
    upcomingPagingItem: T?,
    progress: CGFloat,
    initialContentOffset: CGPoint,
    distance: CGFloat)
}

extension PagingState {
  
  var currentPagingItem: T {
    switch self {
    case let .scrolling(pagingItem, _, _, _, _):
      return pagingItem
    case let .selected(pagingItem):
      return pagingItem
    }
  }
  
  var upcomingPagingItem: T? {
    switch self {
    case let .scrolling(_, upcomingPagingItem, _, _, _):
      return upcomingPagingItem
    case .selected:
      return nil
    }
  }
  
  var progress: CGFloat {
    switch self {
    case let .scrolling(_, _, progress, _, _):
      return progress
    case .selected:
      return 0
    }
  }
  
  var distance: CGFloat {
    switch self {
    case let .scrolling(_, _, _, _, distance):
      return distance
    case .selected:
      return 0
    }
  }
  
  var visuallySelectedPagingItem: T? {
    if fabs(progress) > 0.5 {
      return upcomingPagingItem ?? currentPagingItem
    } else {
      return currentPagingItem
    }
  }
  
}

func ==<T>(lhs: PagingState<T>, rhs: PagingState<T>) -> Bool {
  switch (lhs, rhs) {
  case
    (let .scrolling(lhsCurrent, lhsUpcoming, lhsProgress, lhsOffset, lhsDistance),
     let .scrolling(rhsCurrent, rhsUpcoming, rhsProgress, rhsOffset, rhsDistance)):
    if lhsCurrent == rhsCurrent &&
      lhsProgress == rhsProgress &&
      lhsOffset == rhsOffset &&
      lhsDistance == rhsDistance {
      if let lhsUpcoming = lhsUpcoming, let rhsUpcoming = rhsUpcoming, lhsUpcoming == rhsUpcoming {
        return true
      } else if lhsUpcoming == nil && rhsUpcoming == nil {
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
