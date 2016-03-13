import UIKit

extension UIEdgeInsets {
  
  init(vertical: CGFloat) {
    self.init(top: vertical, left: 0, bottom: vertical, right: 0)
  }
  
  init(hortizontal: CGFloat) {
    self.init(top: 0, left: hortizontal, bottom: 0, right: hortizontal)
  }
  
}
