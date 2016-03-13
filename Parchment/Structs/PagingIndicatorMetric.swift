import Foundation

struct PagingIndicatorMetric {
  
  enum Inset {
    case Left(CGFloat)
    case Right(CGFloat)
    case None
  }
  
  let frame: CGRect
  let insets: Inset
  
  var x: CGFloat {
    switch insets {
    case let .Left(inset):
      return frame.origin.x + inset
    default:
      return frame.origin.x
    }
  }
  
  var width: CGFloat {
    switch insets {
    case let .Left(inset):
      return frame.size.width - inset
    case let .Right(inset):
      return frame.size.width - inset
    case .None:
      return frame.size.width
    }
  }
  
}
