import Foundation

func visibleItems<T: PagingItem where T: Equatable>(
  pagingItem: T,
  width: CGFloat,
  dataSource: PagingViewControllerDataSource,
  presentable: PagingItemPresentable) -> [T] {
  
  let before = itemsBefore([pagingItem],
                           width: width,
                           dataSource: dataSource,
                           presentable: presentable)
  
  let after = itemsAfter([pagingItem],
                         width: width,
                         dataSource: dataSource,
                         presentable: presentable)
  
  return before + [pagingItem] + after
}

func itemsBefore<T: PagingItem where T: Equatable>(
  items: [T],
  width: CGFloat,
  dataSource: PagingViewControllerDataSource,
  presentable: PagingItemPresentable) -> [T] {
  
  if let first = items.first,
    item = dataSource.pagingItemBeforePagingItem(first) as? T where width > 0 {
    return itemsBefore([item] + items,
                       width: width - presentable.widthForPagingItem(item),
                       dataSource: dataSource,
                       presentable: presentable)
  }
  return Array(items.dropLast())
}

func itemsAfter<T: PagingItem where T: Equatable>(
  items: [T],
  width: CGFloat,
  dataSource: PagingViewControllerDataSource,
  presentable: PagingItemPresentable) -> [T] {
  
  if let last = items.last,
    item = dataSource.pagingItemAfterPagingItem(last) as? T where width > 0 {
    return itemsAfter(items + [item],
                      width: width - presentable.widthForPagingItem(item),
                      dataSource: dataSource,
                      presentable: presentable)
  }
  return Array(items.dropFirst())
}

func diffWidth<T: PagingItem where T: Equatable>(
  from from: PagingDataStructure<T>,
       to: PagingDataStructure<T>,
       dataSource: PagingViewControllerDataSource,
       presentable: PagingItemPresentable) -> CGFloat {
  
  let added = widthFromItem(to.visibleItems.first,
                            dataStructure: from,
                            dataSource: dataSource,
                            presentable: presentable)
  
  let removed = widthFromItem(from.visibleItems.first,
                              dataStructure: to,
                              dataSource: dataSource,
                              presentable: presentable)
  
  return added - removed
}

func widthFromItem<T: PagingItem where T: Equatable>(
  item: T?,
  dataStructure: PagingDataStructure<T>,
  dataSource: PagingViewControllerDataSource,
  presentable: PagingItemPresentable,
  width: CGFloat = 0) -> CGFloat {
  
  if dataStructure.visibleItems.isEmpty == false {
    if let item = item where dataStructure.visibleItems.contains(item) == false {
      return widthFromItem(dataSource.pagingItemAfterPagingItem(item) as? T,
                           dataStructure: dataStructure,
                           dataSource: dataSource,
                           presentable: presentable,
                           width: width + presentable.widthForPagingItem(item))
    }
    return width
  }
  return 0
}
