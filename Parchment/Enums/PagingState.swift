import Foundation

enum PagingState<T: PagingItem>: Equatable where T: Equatable {
  case selected(pagingItem: T)
  case scrolling(
    pagingItem: T,
    upcomingPagingItem: T?,
    progress: CGFloat,
    transition: PagingTransition?)
}

extension PagingState {
  
  var currentPagingItem: T {
    switch self {
    case let .scrolling(pagingItem, _, _, _):
      return pagingItem
    case let .selected(pagingItem):
      return pagingItem
    }
  }
  
  var upcomingPagingItem: T? {
    switch self {
    case let .scrolling(_, upcomingPagingItem, _, _):
      return upcomingPagingItem
    case .selected:
      return nil
    }
  }
  
  var progress: CGFloat {
    switch self {
    case let .scrolling(_, _, progress, _):
      return progress
    case .selected:
      return 0
    }
  }
  
  var contentOffset: CGPoint {
    switch self {
    case let .scrolling(_, _, _, transition):
      return transition?.contentOffset ?? .zero
    case .selected:
      return .zero
    }
  }
  
  var distance: CGFloat {
    switch self {
    case let .scrolling(_, _, _, transition):
      return transition?.distance ?? 0
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
  case (let .scrolling(a, b, c, d), let .scrolling(w, x, y, z)):
    if a == w && c == y && d == z {
      if let b = b, let x = x, b == x {
        return true
      } else if b == nil && x == nil {
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
