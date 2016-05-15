import UIKit

public protocol PagingViewControllerDataSource: class {
  func viewControllerForPagingItem(pagingItem: PagingItem) -> UIViewController
  func pagingItemBeforePagingItem(pagingItem: PagingItem) -> PagingItem?
  func pagingItemAfterPagingItem(pagingItem: PagingItem) -> PagingItem?
}
