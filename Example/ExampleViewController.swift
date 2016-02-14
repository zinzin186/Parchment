import UIKit
import Cartography

class ExampleViewController: UIViewController {
  
  init(index: Int) {
    super.init(nibName: nil, bundle: nil)
    title = "View \(index)"
    label.text = "\(index)"
    label.sizeToFit()
    view.addSubview(label)
    view.backgroundColor = UIColor.whiteColor()
    constrain(view, label) { view, label in
      label.centerX == view.centerX
      label.centerY == view.centerY
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = UIFont(name: "HelveticaNeue-Thin", size: 70)
    label.textColor = UIColor.lightGrayColor()
    return label
  }()
  
}