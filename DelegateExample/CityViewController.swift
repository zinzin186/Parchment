import UIKit

class CityViewController: UIViewController {
  
  init(title: String) {
    super.init(nibName: nil, bundle: nil)
    self.title = title
    
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFontOfSize(50, weight: UIFontWeightThin)
    label.textColor = UIColor(red: 95/255, green: 102/255, blue: 108/255, alpha: 1)
    label.text = title
    label.sizeToFit()
    
    view.addSubview(label)
    view.constrainCentered(label)
    view.backgroundColor = .whiteColor()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
