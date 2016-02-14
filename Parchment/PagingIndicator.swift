import UIKit

class PagingIndicator: UICollectionReusableView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  private func configure() {
    backgroundColor = UIColor.blueColor()
  }
  
}
