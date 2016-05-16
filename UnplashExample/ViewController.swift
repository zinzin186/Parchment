import UIKit
import Parchment

// First thing we need to do is create our own PagingItem that will
// hold the data for the different menu items. The header image is the
// image that will be displayed in the menu and the title will be
// overlayed above that.  We also need to store the array of images
// that we want to show when the item is tapped.
struct ImageItem: PagingItem, Equatable {
  let title: String
  let headerImage: UIImage
  let images: [UIImage]
}

func ==(lhs: ImageItem, rhs: ImageItem) -> Bool {
  return (
    lhs.title == rhs.title &&
    lhs.headerImage == rhs.headerImage &&
    lhs.images == rhs.images)
}

// Lets create our own custom theme.
struct ImagePagingTheme: PagingTheme {
  let borderColor: UIColor = UIColor(white: 0, alpha: 0.1)
  let indicatorColor: UIColor = .blackColor()
}

// We need to create our own options struct in order to customize it
// to our needs. First, we need to set our custom PagingCell class
// which will display our images. We set the cells to be fixed and add
// some spacing around them. We also customize the looks of the border
// and the paging indicator.
struct ImagePagingOptions: PagingOptions {
  let menuItemClass: PagingCell.Type = ImagePagingCell.self
  let menuItemSize: PagingMenuItemSize = .Fixed(width: 70, height: 70)
  let menuItemSpacing: CGFloat = 8
  let menuInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
  let theme: PagingTheme = ImagePagingTheme()
  
  let indicatorOptions: PagingIndicatorOptions = .Visible(
    height: 1,
    zIndex: Int.max,
    insets: UIEdgeInsets())
  
  let borderOptions: PagingBorderOptions = .Visible(
    height: 1,
    zIndex: Int.max - 1,
    insets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18))
}

class ViewController: UIViewController {

  // Initialize our PagingViewController with our custom options. Note
  // that we also need to specify the generic type as our ImageItem
  lazy var pagingViewController: PagingViewController<ImageItem> = {
    return PagingViewController(options: ImagePagingOptions())
  }()

  // Our data source is responsible for holding the paging items and
  // telling the paging view controller what paging item comes before
  // or after any given item.
  private let dataSource = ImagePagingDataSource()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Add the paging view controller as a child view controller and
    // contrain it to all edges.
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMoveToParentViewController(self)
    
    // Set our custom data source.
    pagingViewController.dataSource = dataSource
    
    // Set the first item as the selected paging item.
    pagingViewController.selectPagingItem(dataSource.items.first!)
  }

}
