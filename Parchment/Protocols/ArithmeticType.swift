import Foundation

protocol ArithmeticType {
  func +(lhs: Self, rhs: Self) -> Self
  func -(lhs: Self, rhs: Self) -> Self
  func /(lhs: Self, rhs: Self) -> Self
  func *(lhs: Self, rhs: Self) -> Self
  func %(lhs: Self, rhs: Self) -> Self
}

extension CGFloat: ArithmeticType {}

func tween<T: ArithmeticType>(from from: T, to: T, progress: T) -> T {
  return ((to - from) * progress) + from
}
