import UIKit

public protocol PagingViewControllerDataSource: class {
  func initialPagingItem() -> PagingItem?
  func viewControllerForPagingItem(pagingItem: PagingItem) -> UIViewController
  func pagingItemBeforePagingItem(pagingItem: PagingItem) -> PagingItem?
  func pagingItemAfterPagingItem(pagingItem: PagingItem) -> PagingItem?
}
