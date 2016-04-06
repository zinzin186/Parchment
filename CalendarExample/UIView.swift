import UIKit

extension UIView {
  
  func constrainCentered(subview: UIView) {
    
    subview.translatesAutoresizingMaskIntoConstraints = false
    
    let verticalContraint = NSLayoutConstraint(
      item: subview,
      attribute: .CenterY,
      relatedBy: .Equal,
      toItem: self,
      attribute: .CenterY,
      multiplier: 1.0,
      constant: 0)
    
    let horizontalContraint = NSLayoutConstraint(
      item: subview,
      attribute: .CenterX,
      relatedBy: .Equal,
      toItem: self,
      attribute: .CenterX,
      multiplier: 1.0,
      constant: 0)
    
    let heightContraint = NSLayoutConstraint(
      item: subview,
      attribute: .Height,
      relatedBy: .Equal,
      toItem: nil,
      attribute: .NotAnAttribute,
      multiplier: 1.0,
      constant: subview.frame.height)
    
    let widthContraint = NSLayoutConstraint(
      item: subview,
      attribute: .Width,
      relatedBy: .Equal,
      toItem: nil,
      attribute: .NotAnAttribute,
      multiplier: 1.0,
      constant: subview.frame.width)
    
    addConstraints([
      horizontalContraint,
      verticalContraint,
      heightContraint,
      widthContraint])
    
  }
  
  func constrainToEdges(subview: UIView) {
    
    subview.translatesAutoresizingMaskIntoConstraints = false
    
    let topContraint = NSLayoutConstraint(
      item: subview,
      attribute: .Top,
      relatedBy: .Equal,
      toItem: self,
      attribute: .Top,
      multiplier: 1.0,
      constant: 0)
    
    let bottomConstraint = NSLayoutConstraint(
      item: subview,
      attribute: .Bottom,
      relatedBy: .Equal,
      toItem: self,
      attribute: .Bottom,
      multiplier: 1.0,
      constant: 0)
    
    let leadingContraint = NSLayoutConstraint(
      item: subview,
      attribute: .Leading,
      relatedBy: .Equal,
      toItem: self,
      attribute: .Leading,
      multiplier: 1.0,
      constant: 0)
    
    let trailingContraint = NSLayoutConstraint(
      item: subview,
      attribute: .Trailing,
      relatedBy: .Equal,
      toItem: self,
      attribute: .Trailing,
      multiplier: 1.0,
      constant: 0)
    
    addConstraints([
      topContraint,
      bottomConstraint,
      leadingContraint,
      trailingContraint])
  }
  
}
