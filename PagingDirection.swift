import Foundation

enum PagingDirection {
  case Reverse, Forward
}

extension PagingDirection {
  
  var pageViewControllerNavigationDirection: UIPageViewControllerNavigationDirection {
    switch self {
    case .Forward:
      return .Forward
    case .Reverse:
      return .Reverse
    }
  }
  
}
