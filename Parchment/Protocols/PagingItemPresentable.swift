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
  
  func diffWidth<T: PagingItem where T: Equatable>(from from: PagingDataStructure<T>, to: PagingDataStructure<T>) -> CGFloat {
    let added = widthFromItem(to.visibleItems.first, dataStructure: from)
    let removed = widthFromItem(from.visibleItems.first, dataStructure: to)
    return added - removed
  }
  
  func widthFromItem<T: PagingItem where T: Equatable>(item: T?, dataStructure: PagingDataStructure<T>, width: CGFloat = 0) -> CGFloat {
    if dataStructure.visibleItems.isEmpty == false {
      if let item = item where dataStructure.visibleItems.contains(item) == false {
        return widthFromItem(pagingItemAfterPagingItem(item),
                             dataStructure: dataStructure,
                             width: width + widthForPagingItem(item))
      }
      return width
    }
    return 0
  }
  
}