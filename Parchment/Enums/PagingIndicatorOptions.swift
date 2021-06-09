import UIKit

public enum PositionIndicator {
    case left(CGFloat)
    case center(CGFloat)
    case right(CGFloat)
    
    func getWidth() -> CGFloat {
        switch self {
        case .left(let width):
            return width
        case .center(let width):
            return width
        case .right(let width):
            return width
        }
    }
}

public enum PagingIndicatorOptions {
    case hidden
    case visible(
        height: CGFloat,
        zIndex: Int,
        spacing: UIEdgeInsets,
        insets: UIEdgeInsets,
            position: PositionIndicator? = nil
    )
}
