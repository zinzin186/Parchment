import UIKit

protocol Reusable: class {
  static var reuseIdentifier: String { get }
}

extension Reusable where Self: UIView {
  static var reuseIdentifier: String {
    return String(self)
  }
}

extension UICollectionReusableView: Reusable {}

extension UICollectionViewLayout {
  
  func registerDecorationView<T: UICollectionReusableView where T: Reusable>(_: T.Type) {
    registerClass(T.self, forDecorationViewOfKind: T.reuseIdentifier)
  }
  
}

extension UICollectionView {
  
  func registerReusableCell<T: UICollectionViewCell where T: Reusable>(cellType: T.Type) {
    self.registerClass(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
  }
  
  func dequeueReusableCell<T: UICollectionViewCell where T: Reusable>(indexPath indexPath: NSIndexPath, cellType: T.Type = T.self) -> T {
    guard let cell = self.dequeueReusableCellWithReuseIdentifier(cellType.reuseIdentifier, forIndexPath: indexPath) as? T else {
      fatalError("could not dequeue reusable cell with identifier \(cellType.reuseIdentifier)")
    }
    return cell
  }
  
}
