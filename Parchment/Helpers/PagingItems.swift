import Foundation

func visibleItems<T: PagingItem where T: Equatable>(
  pagingItem: T,
  width: CGFloat,
  dataSource: PagingViewControllerDataSource,
  delegate: PagingViewControllerDelegate) -> [T] {
  
  let before = itemsBefore([pagingItem],
                           width: width,
                           dataSource: dataSource,
                           delegate: delegate)
  
  let after = itemsAfter([pagingItem],
                         width: width,
                         dataSource: dataSource,
                         delegate: delegate)
  
  return before + [pagingItem] + after
}

func itemsBefore<T: PagingItem where T: Equatable>(
  items: [T],
  width: CGFloat,
  dataSource: PagingViewControllerDataSource,
  delegate: PagingViewControllerDelegate) -> [T] {
  
  if let first = items.first,
    item = dataSource.pagingItemBeforePagingItem(first) as? T where width > 0 {
    return itemsBefore([item] + items,
                       width: width - delegate.widthForPagingItem(item),
                       dataSource: dataSource,
                       delegate: delegate)
  }
  return Array(items.dropLast())
}

func itemsAfter<T: PagingItem where T: Equatable>(
  items: [T],
  width: CGFloat,
  dataSource: PagingViewControllerDataSource,
  delegate: PagingViewControllerDelegate) -> [T] {
  
  if let last = items.last,
    item = dataSource.pagingItemAfterPagingItem(last) as? T where width > 0 {
    return itemsAfter(items + [item],
                      width: width - delegate.widthForPagingItem(item),
                      dataSource: dataSource,
                      delegate: delegate)
  }
  return Array(items.dropFirst())
}

func diffWidth<T: PagingItem where T: Equatable>(
  from from: PagingDataStructure<T>,
       to: PagingDataStructure<T>,
       dataSource: PagingViewControllerDataSource,
       delegate: PagingViewControllerDelegate) -> CGFloat {
  
  let added = widthFromItem(to.visibleItems.first,
                            dataStructure: from,
                            dataSource: dataSource,
                            delegate: delegate)
  
  let removed = widthFromItem(from.visibleItems.first,
                              dataStructure: to,
                              dataSource: dataSource,
                              delegate: delegate)
  
  return added - removed
}

func widthFromItem<T: PagingItem where T: Equatable>(
  item: T?,
  dataStructure: PagingDataStructure<T>,
  dataSource: PagingViewControllerDataSource,
  delegate: PagingViewControllerDelegate,
  width: CGFloat = 0) -> CGFloat {
  if dataStructure.visibleItems.isEmpty == false {
    if let item = item where dataStructure.visibleItems.contains(item) == false {
      return widthFromItem(dataSource.pagingItemAfterPagingItem(item) as? T,
                           dataStructure: dataStructure,
                           dataSource: dataSource,
                           delegate: delegate,
                           width: width + delegate.widthForPagingItem(item))
    }
    return width
  }
  return 0
}
