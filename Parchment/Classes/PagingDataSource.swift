import UIKit

class PagingDataSource: NSObject {
  
  var viewControllers: [UIViewController]
  private let options: PagingOptions
  
  init(viewControllers: [UIViewController], options: PagingOptions) {
    self.viewControllers = viewControllers
    self.options = options
    super.init()
  }
  
}

extension PagingDataSource: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell: PagingCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
    cell.viewModel = PagingCellViewModel(
      title: viewControllers[indexPath.row].title,
      theme: options.theme)
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewControllers.count
  }
  
}

extension PagingDataSource: UIPageViewControllerDataSource {
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    if let index = self.viewControllers.indexOf(viewController) where index > 0 {
      return self.viewControllers[index - 1]
    }
    return nil
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    if let index = self.viewControllers.indexOf(viewController) where index < self.viewControllers.count - 1 {
      return self.viewControllers[index + 1]
    }
    return nil
  }
  
}