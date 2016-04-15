import Foundation

public protocol PagingViewControllerDelegate: class {
  func pagingViewController<T>(pagingViewController: PagingViewController<T>,
                            widthForPagingItem pagingItem: T) -> CGFloat
}
