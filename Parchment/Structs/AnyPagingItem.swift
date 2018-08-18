import Foundation

struct AnyPagingItem: PagingItem, Hashable, Comparable {
  let base: PagingItem
  
  init(base: PagingItem) {
    self.base = base
  }
  
  var hashValue: Int {
    return base.identifier
  }
  
  static func < (lhs: AnyPagingItem, rhs: AnyPagingItem) -> Bool {
    return lhs.base.isBefore(item: rhs.base)
  }
  
  static func == (lhs: AnyPagingItem, rhs: AnyPagingItem) -> Bool {
    return lhs.base.isEqual(to: rhs.base)
  }
}
