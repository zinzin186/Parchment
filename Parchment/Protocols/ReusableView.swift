import UIKit

protocol ReusableView: class {
  static var reuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
  static var reuseIdentifier: String {
    return String(self)
  }
}

extension UICollectionReusableView: ReusableView {}
