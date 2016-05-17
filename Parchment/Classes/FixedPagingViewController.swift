import UIKit

public struct PagingViewControllerItem: PagingTitleItem, Equatable {
  
  public let viewController: UIViewController
  public let title: String
  
  init(viewController: UIViewController) {
    self.viewController = viewController
    self.title = viewController.title ?? ""
  }
}

public func ==(lhs: PagingViewControllerItem, rhs: PagingViewControllerItem) -> Bool {
  return lhs.viewController == rhs.viewController
}

public class FixedPagingViewController: PagingViewController<PagingViewControllerItem> {
  
  let items: [PagingViewControllerItem]
  
  public init(viewControllers: [UIViewController], options: PagingOptions = DefaultPagingOptions()) {
    items = viewControllers.map { PagingViewControllerItem(viewController: $0) }
    super.init(options: options)
    dataSource = self
    
  }
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if let item = items.first {
      selectPagingItem(item)
    }
  }
  
}

extension FixedPagingViewController: PagingViewControllerDataSource {
  
  public func viewControllerForPagingItem(pagingItem: PagingItem) -> UIViewController {
    let index = items.indexOf(pagingItem as! PagingViewControllerItem)!
    return items[index].viewController
  }
  
  public func pagingItemBeforePagingItem(pagingItem: PagingItem) -> PagingItem? {
    guard let index = items.indexOf(pagingItem as! PagingViewControllerItem) else { return nil }
    if index > 0 {
      return items[index - 1]
    }
    return nil
  }
  
  public func pagingItemAfterPagingItem(pagingItem: PagingItem) -> PagingItem? {
    guard let index = items.indexOf(pagingItem as! PagingViewControllerItem) else { return nil }
    if index < items.count - 1 {
      return items[index + 1]
    }
    return nil
  }
  
}