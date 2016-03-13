import UIKit

class DefaultPagingDataSource: PagingViewControllerDataSource {
  
  var viewControllers: [UIViewController]
  
  init(viewControllers: [UIViewController]) {
    self.viewControllers = viewControllers
  }
  
  func numberOfItems() -> Int {
    return viewControllers.count
  }
  
  func titleForIndex(index: Int) -> String? {
    return viewControllers[index].title
  }
  
  func indexOfViewController(viewController: UIViewController) -> Int? {
    return viewControllers.indexOf(viewController)
  }
  
  func viewControllerAtIndex(index: Int) -> UIViewController? {
    return viewControllers[index]
  }
  
}
