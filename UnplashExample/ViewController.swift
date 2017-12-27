import UIKit
import Parchment

// First thing we need to do is create our own PagingItem that will
// hold the data for the different menu items. The header image is the
// image that will be displayed in the menu and the title will be
// overlayed above that.  We also need to store the array of images
// that we want to show when the item is tapped.
struct ImageItem: PagingItem, Hashable, Comparable {
  let index: Int
  let title: String
  let headerImage: UIImage
  let images: [UIImage]
  
  var hashValue: Int {
    return title.hashValue + headerImage.hashValue
  }
  
  static func ==(lhs: ImageItem, rhs: ImageItem) -> Bool {
    return (
      lhs.title == rhs.title &&
        lhs.headerImage == rhs.headerImage &&
        lhs.images == rhs.images)
  }
  
  static func <(lhs: ImageItem, rhs: ImageItem) -> Bool {
    return lhs.index < rhs.index
  }
}

class ViewController: UIViewController {

  // Our data source is responsible for holding the paging items and
  // telling the paging view controller what paging item comes before
  // or after any given item.
  fileprivate let dataSource = ImagePagingDataSource()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pagingViewController = PagingViewController<ImageItem>()
    pagingViewController.menuItemClass = ImagePagingCell.self
    pagingViewController.menuItemSize = .fixed(width: 70, height: 70)
    pagingViewController.menuItemSpacing = 8
    pagingViewController.menuInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
    pagingViewController.borderColor = UIColor(white: 0, alpha: 0.1)
    pagingViewController.indicatorColor = .black
    
    pagingViewController.indicatorOptions = .visible(
      height: 1,
      zIndex: Int.max,
      spacing: UIEdgeInsets.zero,
      insets: UIEdgeInsets.zero)
    
    pagingViewController.borderOptions = .visible(
      height: 1,
      zIndex: Int.max - 1,
      insets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18))
    
    // Add the paging view controller as a child view controller and
    // contrain it to all edges.
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParentViewController: self)
    
    // Set our custom data source.
    pagingViewController.dataSource = dataSource
    
    // Set the first item as the selected paging item.
    pagingViewController.selectPagingItem(dataSource.items.first!)
  }

}
