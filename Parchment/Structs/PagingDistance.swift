import Foundation

struct PagingDistance<T: PagingItem> where T: Hashable & Comparable {
  
  let view: UIScrollView
  let state: PagingState<T>?
  let dataStructure: PagingDataStructure<T>
  let sizeCache: PagingSizeCache<T>
  let selectedScrollPosition: PagingSelectedScrollPosition
  let layoutAttributes: [IndexPath: PagingCellLayoutAttributes]
  
  /// In order to get the menu items to scroll alongside the content
  /// we create a transition struct to keep track of the initial
  /// content offset and the distance to the upcoming item so that we
  /// can update the content offset as the user is swiping.
  func calculate() -> CGFloat {
    guard
      let state = state,
      let upcomingPagingItem = state.upcomingPagingItem,
      let upcomingIndexPath = dataStructure.indexPathForPagingItem(upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else {
        
        // When there is no upcomingIndexPath or any layout attributes
        // for that item we have no way to determine the distance.
        return 0
    }
    
    var distance: CGFloat = 0
    
    switch (selectedScrollPosition) {
    case .left:
      distance = distanceLeft()
    case .right:
      distance = distanceRight()
    case .preferCentered:
      distance = distanceCentered()
    }
    
    // Update the distance to account for cases where the user has
    // scrolled all the way over to the other edge.
    if view.near(edge: .left, clearance: -distance) && distance < 0 && dataStructure.hasItemsBefore == false {
      distance = -(view.contentOffset.x + view.contentInset.left)
    } else if view.near(edge: .right, clearance: distance) && distance > 0 &&
      dataStructure.hasItemsAfter == false {
      
      distance = view.contentSize.width - (view.contentOffset.x + view.bounds.width)
      
      if sizeCache.implementsWidthDelegate {
        let toWidth = sizeCache.itemWidthSelected(for: upcomingPagingItem)
        distance += toWidth - to.frame.width
        
        if let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem),
          let from = layoutAttributes[currentIndexPath] {
          let fromWidth = sizeCache.itemWidth(for: state.currentPagingItem)
          distance -= from.frame.width - fromWidth
        }
        
        // If the selected cells grows so much that it will move
        // beyond the center of the view, we want to update the
        // distance after all.
        if selectedScrollPosition == .preferCentered {
          let center = view.bounds.midX
          let centerAfterTransition = to.frame.midX - distance
          if centerAfterTransition < center {
            distance = view.contentSize.width - (view.contentOffset.x + view.bounds.width)
          }
        }
      }
    }
    
    return distance
  }
  
  private func distanceLeft() -> CGFloat {
    guard
      let state = state,
      let upcomingPagingItem = state.upcomingPagingItem,
      let upcomingIndexPath = dataStructure.indexPathForPagingItem(upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else { return 0 }
    
    var distance = to.center.x - (to.bounds.width / 2) - view.contentOffset.x
    
    if sizeCache.implementsWidthDelegate {
      if let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem),
        let from = layoutAttributes[currentIndexPath] {
        if upcomingPagingItem > state.currentPagingItem {
          let fromWidth = sizeCache.itemWidth(for: state.currentPagingItem)
          let fromDiff = from.frame.width - fromWidth
          distance -= fromDiff
        }
      }
    }
    return distance
  }
  
  private func distanceRight() -> CGFloat {
    guard
      let state = state,
      let upcomingPagingItem = state.upcomingPagingItem,
      let upcomingIndexPath = dataStructure.indexPathForPagingItem(upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else { return 0 }
    
    let toWidth = sizeCache.itemWidthSelected(for: upcomingPagingItem)
    let currentPosition = to.frame.origin.x + to.frame.width
    let width = view.contentOffset.x + view.bounds.width
    var distance = currentPosition - width
    
    if sizeCache.implementsWidthDelegate {
      if let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem),
        let from = layoutAttributes[currentIndexPath] {
        if upcomingPagingItem < state.currentPagingItem {
          let toDiff = toWidth - to.frame.width
          distance += toDiff
        } else {
          let fromWidth = sizeCache.itemWidth(for: state.currentPagingItem)
          let fromDiff = from.frame.width - fromWidth
          let toDiff = toWidth - to.frame.width
          distance -= fromDiff
          distance += toDiff
        }
      } else {
        distance += toWidth - to.frame.width
      }
    }
    
    return distance
  }
  
  private func distanceCentered() -> CGFloat {
    guard
      let state = state,
      let upcomingPagingItem = state.upcomingPagingItem,
      let upcomingIndexPath = dataStructure.indexPathForPagingItem(upcomingPagingItem),
      let to = layoutAttributes[upcomingIndexPath] else { return 0 }
    
    let toWidth = sizeCache.itemWidthSelected(for: upcomingPagingItem)
    var distance = to.frame.midX - view.bounds.midX
    
    if let currentIndexPath = dataStructure.indexPathForPagingItem(state.currentPagingItem),
      let from = layoutAttributes[currentIndexPath] {
      
      let distanceToCenter = view.bounds.midX - from.frame.midX
      let distanceBetweenCells = to.frame.midX - from.frame.midX
      distance = distanceBetweenCells - distanceToCenter
      
      if sizeCache.implementsWidthDelegate {
        let fromWidth = sizeCache.itemWidth(for: state.currentPagingItem)
        
        if upcomingPagingItem < state.currentPagingItem {
          distance = -(to.frame.width + (from.frame.midX - to.frame.maxX) - (toWidth / 2)) - distanceToCenter
        } else {
          let toDiff = (toWidth - to.frame.width) / 2
          distance = fromWidth + (to.frame.midX - from.frame.maxX) + toDiff - (from.frame.width / 2) - distanceToCenter
        }
      }
    } else if sizeCache.implementsWidthDelegate {
      let toDiff = toWidth - to.frame.width
      distance += toDiff / 2
    }
    
    return distance
  }
}
