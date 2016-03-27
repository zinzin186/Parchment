import UIKit

public protocol PagingItem {}

public protocol PagingTitleItem: PagingItem {
  var title: String { get }
}

public protocol PagingDataSource: class {
  func initialPagingItem() -> PagingItem?
  func viewControllerForPagingItem(pagingItem: PagingItem) -> UIViewController
  func pagingItemBeforePagingItem(pagingItem: PagingItem) -> PagingItem?
  func pagingItemAfterPagingItem(pagingItem: PagingItem) -> PagingItem?
}
