import UIKit

public struct DefaultPagingItem: PagingTitleItem, Equatable {
  
  public let viewController: UIViewController
  public let title: String
  
  init(viewController: UIViewController) {
    self.viewController = viewController
    self.title = viewController.title ?? ""
  }
}

public func ==(lhs: DefaultPagingItem, rhs: DefaultPagingItem) -> Bool {
  return lhs.viewController == rhs.viewController
}

public class DefaultPagingViewController: PagingViewController<DefaultPagingItem> {
  
  let items: [DefaultPagingItem]
  
  public init(viewControllers: [UIViewController], options: PagingOptions = DefaultPagingOptions()) {
    items = viewControllers.map { DefaultPagingItem(viewController: $0) }
    super.init(options: options)
    dataSource = self
    
    if let item = items.first {
      selectPagingItem(item)
    }
  }
  
}

extension DefaultPagingViewController: PagingViewControllerDataSource {
  
  public func viewControllerForPagingItem(pagingItem: PagingItem) -> UIViewController {
    let index = items.indexOf(pagingItem as! DefaultPagingItem)!
    return items[index].viewController
  }
  
  public func pagingItemBeforePagingItem(pagingItem: PagingItem) -> PagingItem? {
    guard let index = items.indexOf(pagingItem as! DefaultPagingItem) else { return nil }
    if index > 0 {
      return items[index - 1]
    }
    return nil
  }
  
  public func pagingItemAfterPagingItem(pagingItem: PagingItem) -> PagingItem? {
    guard let index = items.indexOf(pagingItem as! DefaultPagingItem) else { return nil }
    if index < items.count - 1 {
      return items[index + 1]
    }
    return nil
  }
  
}