import UIKit
import Parchment

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let viewControllers = (0...10).map { ExampleViewController(index: $0) }
    let pagingViewController = DefaultPagingViewController(viewControllers: viewControllers)

    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMoveToParentViewController(self)
  }
  
}
