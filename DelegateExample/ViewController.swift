import UIKit
import Parchment

class ViewController: UIViewController {
  
  let cities = [
    "Oslo",
    "Stockholm",
    "Barcelona",
    "Vancouver",
    "Berlin",
    "Oslo",
    "Stockholm",
    "Barcelona",
    "Vancouver",
    "Berlin",
    "Oslo",
    "Stockholm",
    "Barcelona",
    "Vancouver",
    "Berlin"]
  
  lazy var pagingViewController: DefaultPagingViewController = {
    return DefaultPagingViewController(viewControllers: self.cities.map {
      return ExampleViewController(title: $0)
    })
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pagingViewController.delegate = self
    
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.addConstraintsForFullscreenSubview(pagingViewController.view)
    pagingViewController.didMoveToParentViewController(self)
  }
  
}

extension ViewController: PagingViewControllerDelegate {
  
  func widthForPagingItem(pagingItem: PagingItem) -> CGFloat {
    guard let item = pagingItem as? PagingTitleItem else { return 0 }
    
    let options = pagingViewController.options
    let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    let size = CGSize(width: CGFloat.max, height: options.menuItemSize.height)
    let attributes = [NSFontAttributeName: options.theme.font]
    let rect = item.title.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
    
    return ceil(rect.width) + insets.left + insets.right
  }
  
}
