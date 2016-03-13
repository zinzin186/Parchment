import Foundation

func tween<T: ArithmeticType>(from from: T, to: T, progress: T) -> T {
  return ((to - from) * progress) + from
}
