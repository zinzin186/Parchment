import UIKit
import Parchment

class MultipleCellsViewController: UIViewController {

    let items: [PagingItem] = [
        IconItem(icon: "earth", index: 0),
        PagingIndexItem(index: 1, title: "TODO"),
        PagingIndexItem(index: 2, title: "In Progress"),
        PagingIndexItem(index: 3, title: "Archive"),
        PagingIndexItem(index: 4, title: "Other")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pagingViewController = PagingViewController()
        pagingViewController.sizeDelegate = self
        pagingViewController.register(IconPagingCell.self, for: IconItem.self)
        pagingViewController.register(PagingTitleCell.self, for: PagingIndexItem.self)
        pagingViewController.menuItemSize = .fixed(width: 60, height: 60)
        pagingViewController.dataSource = self
        pagingViewController.select(index: 0)
        
        // Add the paging view controller as a child view controller
        // and contrain it to all edges.
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
    }


}

extension MultipleCellsViewController: PagingViewControllerDataSource {
  
  func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
    return TableViewController()
  }
  
  func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
    return items[index]
  }
  
  func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
    return items.count
  }
  
}

extension MultipleCellsViewController: PagingViewControllerSizeDelegate {
  
  // We want the size of our paging items to equal the width of the
  // city title. Parchment does not support self-sizing cells at
  // the moment, so we have to handle the calculation ourself. We
  // can access the title string by casting the paging item to a
  // PagingTitleItem, which is the PagingItem type used by
  // FixedPagingViewController.
  func pagingViewController(_ pagingViewController: PagingViewController, widthForPagingItem pagingItem: PagingItem, isSelected: Bool) -> CGFloat {
    guard let item = pagingItem as? PagingIndexItem else { return 50 }
    
    let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: pagingViewController.options.menuItemSize.height)
    let attributes = [NSAttributedString.Key.font: pagingViewController.options.font]
    
    let rect = item.title.boundingRect(with: size,
                                       options: .usesLineFragmentOrigin,
                                       attributes: attributes,
                                       context: nil)
    
    let width = ceil(rect.width) + insets.left + insets.right
    return width
  }
  
}
