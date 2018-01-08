import Foundation

public struct PagingItems<T: PagingItem> where T: Hashable & Comparable {
  
  public let items: [T]
  
  let hasItemsBefore: Bool
  let hasItemsAfter: Bool
  let itemsCache: Set<T>
  
  init(items: [T], hasItemsBefore: Bool = false, hasItemsAfter: Bool = false) {
    self.items = items
    self.hasItemsBefore = hasItemsBefore
    self.hasItemsAfter = hasItemsAfter
    self.itemsCache = Set(items)
  }
  
  public func indexPath(for pagingItem: T) -> IndexPath? {
    guard let index = items.index(of: pagingItem) else { return nil }
    return IndexPath(item: index, section: 0)
  }
  
  public func pagingItem(for indexPath: IndexPath) -> T {
    return items[indexPath.item]
  }
  
  public func direction(from: T, to: T) -> PagingDirection {
    if itemsCache.contains(from) == false {
      return .none
    } else if to > from {
      return .forward
    } else if to < from {
      return .reverse
    }
    return .none
  }
}
