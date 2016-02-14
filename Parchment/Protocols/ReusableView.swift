import UIKit

protocol ReusableView: class {
  static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
  static var defaultReuseIdentifier: String {
    return NSStringFromClass(self)
  }
}

extension UICollectionReusableView: ReusableView {}
