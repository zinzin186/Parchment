import UIKit
import Parchment

// We need to create our own options struct in order to customize it
// to our needs. First, we need to set our custom PagingCell class
// which will display our icons. We set the cells to be a fixed size
// and customize the looks of the paging indicator.
struct IconsPagingOptions: PagingOptions {
  let menuItemClass: PagingCell.Type = IconPagingCell.self
  let menuItemSize: PagingMenuItemSize = .fixed(width: 60, height: 60)
  let theme: PagingTheme = IconsPagingTheme()
}

// Let's create our own custom theme.
struct IconsPagingTheme: PagingTheme {
  let textColor = UIColor(red: 132/255, green: 140/255, blue: 145/255, alpha: 1)
  let selectedTextColor = UIColor(red: 38/255, green: 197/255, blue: 218/255, alpha: 1)
  let indicatorColor = UIColor(red: 38/255, green: 197/255, blue: 218/255, alpha: 1)
}

class ViewController: UIViewController {
  
  // Let's start by creating an array of icon names that
  // we will use to generate some view controllers.
  fileprivate let icons = [
    "compass",
    "cloud",
    "bonnet",
    "axe",
    "earth",
    "knife",
    "leave",
    "light",
    "map",
    "moon",
    "mushroom",
    "shoes",
    "snow",
    "star",
    "sun",
    "tipi",
    "tree",
    "water",
    "wind",
    "wood"
  ]
  
  // Map over the icons in the array and initialize a new view
  // controller with the name of that icon.
  fileprivate lazy var viewControllers: [UIViewController] = {
    return self.icons.map { IconViewController(title: $0) }
  }()
  
  // Initialize a PagingViewController with our array of view
  // controllers. Note that we're using FixedPagingViewController,
  // which is a subclass of PagingViewController that takes in an
  // array of view controllers and handles setting up the data
  // source and paging items for us.
  fileprivate lazy var pagingViewController: FixedPagingViewController = {
    return FixedPagingViewController(
      viewControllers: self.viewControllers,
      options: IconsPagingOptions())
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Add the paging view controller as a child view controller
    // and contrain it to all edges.
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParentViewController: self)
  }
  
}
