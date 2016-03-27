import Foundation

class PagingStateMachine<T: PagingItem where T: Equatable> {
  
  var eventObservers: [(stateMachine: PagingStateMachine<T>, event: PagingEvent<T>) -> Void] = []
  var stateObservers: [(stateMachine: PagingStateMachine<T>, oldState: PagingState<T>?) -> Void] = [] {
    didSet {
      notifyStateObservers(nil)
    }
  }
  
  var state: PagingState<T> {
    return internalState
  }
  
  private var internalState: PagingState<T> {
    didSet {
      if oldValue != internalState {
        notifyStateObservers(oldValue)
      }
    }
  }
  
  init(initialPagingItem: T) {
    internalState = .Current(pagingItem: initialPagingItem)
  }
  
  func fire(event: PagingEvent<T>) {
    switch event {
    case let .DidMove(pagingItem):
      handleDidMoveToPagingItemEvent(pagingItem)
    case let .Update(offset):
      handleUpdateOffsetEvent(offset)
    case let .Select(pagingItem, direction):
      handleSelectEvent(pagingItem, direction: direction)
    case let .DidBeginDragging(upcomingPagingItem, direction):
      handleDidBeginDraggingEvent(upcomingPagingItem, direction: direction)
    }
    
    notifyEventObservers(event)
  }
  
  private func notifyEventObservers(event: PagingEvent<T>) {
    for observer in self.eventObservers {
      observer(stateMachine: self, event: event)
    }
  }
  
  private func notifyStateObservers(oldState: PagingState<T>?) {
    for observer in stateObservers {
      observer(stateMachine: self, oldState: oldState)
    }
  }
  
  private func handleSelectEvent(pagingItem: T, direction: PagingDirection) {
    switch direction {
    case .Reverse:
      internalState = .Previous(
        pagingItem: state.currentPagingItem,
        upcomingPagingItem: pagingItem,
        offset: 0)
    case .Forward:
      internalState = .Next(
        pagingItem: state.currentPagingItem,
        upcomingPagingItem: pagingItem,
        offset: 0)
    default:
      break
    }
  }
  
  private func handleUpdateOffsetEvent(offset: CGFloat) {
    if offset > 0 {
      internalState = .Next(
        pagingItem: state.currentPagingItem,
        upcomingPagingItem: state.upcomingPagingItem,
        offset: offset)
    } else if offset < 0 {
      internalState = .Previous(
        pagingItem: state.currentPagingItem,
        upcomingPagingItem: state.upcomingPagingItem,
        offset: offset)
    }
  }
  
  private func handleDidMoveToPagingItemEvent(pagingItem: T) {
    internalState = .Current(pagingItem: pagingItem)
  }
  
  private func handleDidBeginDraggingEvent(upcomingPagingItem: T?, direction: PagingDirection) {
    switch direction {
    case .Forward:
      internalState = .Next(
        pagingItem: state.currentPagingItem,
        upcomingPagingItem: upcomingPagingItem,
        offset: state.offset)
    case .Reverse:
      internalState = .Previous(
        pagingItem: state.currentPagingItem,
        upcomingPagingItem: upcomingPagingItem,
        offset: state.offset)
    default:
      break
    }
  }
    
}
