import Foundation

protocol ArithmeticType {
  func +(lhs: Self, rhs: Self) -> Self
  func -(lhs: Self, rhs: Self) -> Self
  func /(lhs: Self, rhs: Self) -> Self
  func *(lhs: Self, rhs: Self) -> Self
  func %(lhs: Self, rhs: Self) -> Self
}

extension CGFloat: ArithmeticType {}
