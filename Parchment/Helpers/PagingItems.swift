import Foundation

func visibleItems<T: PagingItem where T: Equatable>(pagingItem: T, width: CGFloat, dataSource: PagingDataSource, options: PagingOptions) -> [T] {
  
  let before = itemsBefore([pagingItem],
                           width: width,
                           dataSource: dataSource,
                           options: options)
  
  let after = itemsAfter([pagingItem],
                         width: width,
                         dataSource: dataSource,
                         options: options)
  
  return before + [pagingItem] + after
}

func itemsBefore<T: PagingItem where T: Equatable>(items: [T], width: CGFloat, dataSource: PagingDataSource, options: PagingOptions) -> [T] {
  if let first = items.first, item = dataSource.pagingItemBeforePagingItem(first) as? T where width > 0 {
    return itemsBefore([item] + items,
                       width: width - options.menuItemSize.width,
                       dataSource: dataSource,
                       options: options)
  }
  return Array(items.dropLast())
}

func itemsAfter<T: PagingItem where T: Equatable>(items: [T], width: CGFloat, dataSource: PagingDataSource, options: PagingOptions) -> [T] {
  if let last = items.last, item = dataSource.pagingItemAfterPagingItem(last) as? T where width > 0 {
    return itemsAfter(items + [item],
                      width: width - options.menuItemSize.width,
                      dataSource: dataSource,
                      options: options)
  }
  return Array(items.dropFirst())
}

func diffWidth<T: PagingItem where T: Equatable>(from from: PagingDataStructure<T>, to: PagingDataStructure<T>, dataSource: PagingDataSource, options: PagingOptions) -> CGFloat {
  
  let added = widthFromItem(to.visibleItems.first,
                            dataStructure: from,
                            dataSource: dataSource,
                            options: options)
  
  let removed = widthFromItem(from.visibleItems.first,
                              dataStructure: to,
                              dataSource: dataSource,
                              options: options)
  
  return added - removed
}

func widthFromItem<T: PagingItem where T: Equatable>(item: T?, dataStructure: PagingDataStructure<T>, dataSource: PagingViewControllerDataSource, options: PagingOptions, width: CGFloat = 0) -> CGFloat {
  if let item = item where dataStructure.visibleItems.contains(item) == false {
    return widthFromItem(dataSource.pagingItemAfterPagingItem(item) as? T,
                         dataStructure: dataStructure,
                         dataSource: dataSource,
                         options: options,
                         width: width + options.menuItemSize.width)
  }
  return width
}
