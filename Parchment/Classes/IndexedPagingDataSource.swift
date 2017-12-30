import Foundation

class IndexedPagingDataSource<T: PagingItem>: PagingViewControllerInfiniteDataSource where T: Hashable & Comparable {
  
  let items: [T]
  let viewControllerForIndex: (Int) -> UIViewController
  
  init(items: [T], viewControllerForIndex: @escaping (Int) -> UIViewController) {
    self.items = items
    self.viewControllerForIndex = viewControllerForIndex
  }
  
  func pagingViewController<U>(_ pagingViewController: PagingViewController<U>, viewControllerForPagingItem item: U) -> UIViewController {
    guard let index = items.index(of: item as! T) else {
      fatalError("pagingViewController:viewControllerForPagingItem: PagingItem does not exist")
    }
    return viewControllerForIndex(index)
  }
  
  func pagingViewController<U>(_ pagingViewController: PagingViewController<U>, pagingItemBeforePagingItem item: U) -> U? {
    guard let index = items.index(of: item as! T) else { return nil }
    if index > 0 {
      return items[index - 1] as? U
    }
    return nil
  }
  
  func pagingViewController<U>(_ pagingViewController: PagingViewController<U>, pagingItemAfterPagingItem item: U) -> U? {
    guard let index = items.index(of: item as! T) else { return nil }
    if index < items.count - 1 {
      return items[index + 1] as? U
    }
    return nil
  }
}
