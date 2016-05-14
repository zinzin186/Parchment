import Foundation

protocol PagingItemsPresentable {
  func widthForPagingItem<T: PagingItem>(pagingItem: T) -> CGFloat
  func pagingItemBeforePagingItem<T: PagingItem>(pagingItem: T) -> T?
  func pagingItemAfterPagingItem<T: PagingItem>(pagingItem: T) -> T?
}

extension PagingItemsPresentable {
  
  func visibleItems<T: PagingItem where T: Equatable>(pagingItem: T, width: CGFloat) -> [T] {
    let before = itemsBefore([pagingItem], width: width)
    let after = itemsAfter([pagingItem], width: width)
    return before + [pagingItem] + after
  }
  
  func itemsBefore<T: PagingItem where T: Equatable>(items: [T], width: CGFloat) -> [T] {
    if let first = items.first, item = pagingItemBeforePagingItem(first) where width > 0 {
      return itemsBefore([item] + items, width: width - widthForPagingItem(item))
    }
    return Array(items.dropLast())
  }
  
  func itemsAfter<T: PagingItem where T: Equatable>(items: [T], width: CGFloat) -> [T] {
    if let last = items.last, item = pagingItemAfterPagingItem(last) where width > 0 {
      return itemsAfter(items + [item], width: width - widthForPagingItem(item))
    }
    return Array(items.dropFirst())
  }
  
  func diffWidth<T: PagingItem where T: Equatable>(from from: [T], to: [T]) -> CGFloat {
    let added = widthFromItem(to.first, items: from)
    let removed = widthFromItem(from.first, items: to)
    return added - removed
  }
  
  func widthFromItem<T: PagingItem where T: Equatable>(item: T?, items: [T], width: CGFloat = 0) -> CGFloat {
    if items.isEmpty == false {
      if let item = item where items.contains(item) == false {
        return widthFromItem(pagingItemAfterPagingItem(item),
                             items: items,
                             width: width + widthForPagingItem(item))
      }
      return width
    }
    return 0
  }
  
}