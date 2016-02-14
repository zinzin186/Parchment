import UIKit
import Parchment
import Cartography

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pagingViewController = PagingViewController(viewControllers: (0...10).map {
      return ExampleViewController(index: $0)
    })
    
    addChildViewController(pagingViewController)
    view.addSubview(pagingViewController.view)
    pagingViewController.didMoveToParentViewController(self)
    
    constrain(view, pagingViewController.view) { view, pagingView in
      view.edges == pagingView.edges
    }
  }
  
}
