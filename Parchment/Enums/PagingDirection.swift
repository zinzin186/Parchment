import Foundation

enum PagingDirection {
  case Reverse
  case Forward
  case None
}

extension PagingDirection {
  
  var pageViewControllerNavigationDirection: EMPageViewControllerNavigationDirection {
    switch self {
    case .Forward, .None:
      return .Forward
    case .Reverse:
      return .Reverse
    }
  }
  
}
