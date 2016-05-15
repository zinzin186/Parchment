import Foundation

struct PagingDataStructure<T: PagingItem where T: Equatable> {
  
  let visibleItems: [T]
  
  func directionForIndexPath(indexPath: NSIndexPath, currentPagingItem: T) -> PagingDirection {
    guard let currentIndexPath = indexPathForPagingItem(currentPagingItem) else { return .None }
    
    if indexPath.item > currentIndexPath.item {
      return .Forward
    } else if indexPath.item < currentIndexPath.item {
      return .Reverse
    }
    return .None
  }
  
  func indexPathForPagingItem(pagingItem: T) -> NSIndexPath? {
    guard let index = visibleItems.indexOf(pagingItem) else { return nil }
    return NSIndexPath(forItem: index, inSection: 0)
  }
  
  func pagingItemForIndexPath(indexPath: NSIndexPath) -> T {
    return visibleItems[indexPath.item]
  }
  
}
