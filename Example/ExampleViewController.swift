import UIKit

class ExampleViewController: UIViewController {
  
  init(index: Int) {
    super.init(nibName: nil, bundle: nil)
    title = "View \(index)"
    
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFontOfSize(70, weight: UIFontWeightThin)
    label.textColor = .lightGrayColor()
    label.text = "\(index)"
    label.sizeToFit()
    view.addSubview(label)
    view.backgroundColor = .whiteColor()
    view.addConstraintsForCenteredSubview(label)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}