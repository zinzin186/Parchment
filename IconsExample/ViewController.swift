import UIKit
import Parchment

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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Map over the icons in the array and initialize a new view
    // controller with the name of that icon.
    let viewControllers = icons.map { IconViewController(title: $0) }
    
    // Initialize a PagingViewController with our array of view
    // controllers. Note that we're using FixedPagingViewController,
    // which is a subclass of PagingViewController that takes in an
    // array of view controllers and handles setting up the data
    // source and paging items for us.
    let pagingViewController = FixedPagingViewController(viewControllers: viewControllers)
    
    pagingViewController.menuItemClass = IconPagingCell.self
    pagingViewController.menuItemSize = .fixed(width: 60, height: 60)
    pagingViewController.textColor = UIColor(red: 132/255, green: 140/255, blue: 145/255, alpha: 1)
    pagingViewController.selectedTextColor = UIColor(red: 38/255, green: 197/255, blue: 218/255, alpha: 1)
    pagingViewController.indicatorColor = UIColor(red: 38/255, green: 197/255, blue: 218/255, alpha: 1)
    
    // Add the paging view controller as a child view controller
    // and contrain it to all edges.
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParentViewController: self)
  }
  
}
