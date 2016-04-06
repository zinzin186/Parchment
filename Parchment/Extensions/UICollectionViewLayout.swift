import UIKit

extension UICollectionViewLayout {
  
  func registerDecorationView<T: UICollectionReusableView where T: ReusableView>(_: T.Type) {
    registerClass(T.self, forDecorationViewOfKind: T.reuseIdentifier)
  }
  
}
