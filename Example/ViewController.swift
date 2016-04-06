import UIKit
import Parchment

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pagingViewController = DefaultPagingViewController(viewControllers: (0...10).map {
      return ExampleViewController(index: $0)
    })
    
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMoveToParentViewController(self)
  }
  
}
