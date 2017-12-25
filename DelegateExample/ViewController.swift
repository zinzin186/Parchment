import UIKit
import Parchment

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Initialize an array of view controllers that we're going to display.
    let viewControllers = [
      CityViewController(title: "Oslo"),
      CityViewController(title: "Stockholm"),
      CityViewController(title: "Barcelona"),
      CityViewController(title: "Vancouver"),
      CityViewController(title: "Berlin"),
      CityViewController(title: "Shanghai"),
      CityViewController(title: "London"),
      CityViewController(title: "Paris"),
      CityViewController(title: "Chigago"),
      CityViewController(title: "Madrid"),
      CityViewController(title: "Munich"),
      CityViewController(title: "Toronto")
    ]
    
    // Initialize a PagingViewController with our array of view
    // controllers. Note that we're using FixedPagingViewController,
    // which is a subclass of PagingViewController that takes in an
    // array view controllers and handles setting up the data source
    // and paging items for us.
    let pagingViewController = FixedPagingViewController(viewControllers: viewControllers)

    // Add the paging view controller as a child view controller and
    // contrain it to all edges.
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParentViewController: self)

    // Set the paging view controller delegate so that we can handle
    // the width for the paging items.
    pagingViewController.delegate = self
  }
  
}

extension ViewController: PagingViewControllerDelegate {
  
  // We want the size of our paging items to equal the width of the
  // city title. Parchment does not support self-sizing cells at
  // the moment, so we have to handle the calculation ourself. We
  // can access the title string by casting the paging item to a
  // PagingTitleItem, which is the PagingItem type used by
  // FixedPagingViewController.
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, widthForPagingItem pagingItem: T, isSelected: Bool) -> CGFloat {
    
    guard let item = pagingItem as? ViewControllerItem else { return 0 }

    let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: pagingViewController.menuItemSize.height)
    let attributes = [NSAttributedStringKey.font: pagingViewController.font]
    
    let rect = item.title.boundingRect(with: size,
      options: .usesLineFragmentOrigin,
      attributes: attributes,
      context: nil)

    let width = ceil(rect.width) + insets.left + insets.right
    
    if isSelected {
      return width * 1.5
    } else {
      return width
    }
  }
  
}
