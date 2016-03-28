import UIKit

extension UICollectionViewLayout {
  
  func register<T: UICollectionReusableView where T: ReusableView>(_: T.Type) {
    registerClass(T.self, forDecorationViewOfKind: T.defaultReuseIdentifier)
  }
  
}
