import UIKit

class ExampleViewController: UIViewController {
  
  init(title: String) {
    super.init(nibName: nil, bundle: nil)
    self.title = title
    
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFontOfSize(60, weight: UIFontWeightThin)
    label.textColor = .lightGrayColor()
    label.text = title
    label.sizeToFit()
    view.addSubview(label)
    view.backgroundColor = .whiteColor()
    view.constrainCentered(label)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
