import UIKit
import Parchment

class ViewController: UIViewController {

  // Let's start by creating an array of citites that we
  // will use to generate some view controllers.
  private let cities = [
    "Oslo",
    "Stockholm",
    "Tokyo",
    "Barcelona",
    "Vancouver",
    "Berlin",
    "Shanghai",
    "London",
    "Paris",
    "Chicago",
    "Madrid",
    "Munich",
    "Toronto",
    "Sydney",
    "Melbourne"
  ]
  
  // Map over the cities in the array and initialize a new view
  // controller with the name of that city.
  private lazy var viewControllers: [UIViewController] = {
    return self.cities.map { CityViewController(title: $0) }
  }()

  // Initialize a PagingViewController with our array of view
  // controllers. Note that we're using FixedPagingViewController,
  // which is a subclass of PagingViewController that takes in an
  // array view controllers and handles setting up the data source and
  // paging items for us.
  private lazy var pagingViewController: DefaultPagingViewController = {
    return DefaultPagingViewController(viewControllers: self.viewControllers)
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Add the paging view controller as a child view controller and
    // contrain it to all edges.
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMoveToParentViewController(self)

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
  func pagingViewController<T>(pagingViewController: PagingViewController<T>, widthForPagingItem pagingItem: T) -> CGFloat {
    
    guard let item = pagingItem as? PagingTitleItem else { return 0 }
    
    let options = pagingViewController.options
    let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    let size = CGSize(width: CGFloat.max, height: options.menuItemSize.height)
    let attributes = [NSFontAttributeName: options.theme.font]
    
    let rect = item.title.boundingRectWithSize(size,
      options: .UsesLineFragmentOrigin,
      attributes: attributes,
      context: nil)
    
    return ceil(rect.width) + insets.left + insets.right
  }
  
}
