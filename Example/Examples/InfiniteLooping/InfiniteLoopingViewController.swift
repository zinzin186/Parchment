import UIKit
import Parchment

final class InfiniteLoopingViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let pagingViewController = PagingViewController()
    pagingViewController.infiniteDataSource = self

    // Make sure you add the PagingViewController as a child view
    // controller and constrain it to the edges of the view.
    addChild(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParent: self)
    pagingViewController.select(pagingItem: createPagingItem(for: 0))
  }

  private func createPagingItem(for index: Int) -> PagingItem {
    return PagingIndexItem(index: index, title: "View \(index)")
  }
}

/// Implements the `PagingViewControllerInfiniteDataSource` and wraps
/// the items whenever we reaches the end or beginning of the items.
extension InfiniteLoopingViewController: PagingViewControllerInfiniteDataSource {
  func pagingViewController(_: PagingViewController, itemAfter pagingItem: PagingItem) -> PagingItem? {
    let item = pagingItem as! PagingIndexItem
    var index = item.index + 1
    if item.index == 5 {
      index = 0
    }
    return createPagingItem(for: index)
  }

  func pagingViewController(_: PagingViewController, itemBefore pagingItem: PagingItem) -> PagingItem? {
    let item = pagingItem as! PagingIndexItem
    var index = item.index - 1
    if item.index == 0 {
      index = 5
    }
    return createPagingItem(for: index)
  }

  func pagingViewController(_: PagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController {
    let item = pagingItem as! PagingIndexItem
    return ContentViewController(index: item.index)
  }
}
