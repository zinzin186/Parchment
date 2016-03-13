import Foundation

class PagingStateMachine {
  
  var stateObservers: [(stateMachine: PagingStateMachine, oldState: PagingState) -> Void] = []
  var eventObservers: [(stateMachine: PagingStateMachine, event: PagingEvent) -> Void] = []
  
  var state: PagingState {
    return internalState
  }
  
  private var internalState: PagingState = .Current(index: 0) {
    didSet {
      if oldValue != internalState {
        for observer in self.stateObservers {
          observer(stateMachine: self, oldState: oldValue)
        }
      }
    }
  }
  
  func fire(event: PagingEvent) {
    switch event {
    case let .DidMove(index: index):
      handleDidMoveToIndexEvent(index)
    case let .Update(offset: offset):
      handleUpdateOffsetEvent(offset)
    case let .Select(index: index):
      handleSelectEvent(index)
    }
    
    for observer in self.eventObservers {
      observer(stateMachine: self, event: event)
    }
  }
  
  func directionForIndex(index: Int) -> PagingDirection {
    if state.currentIndex > index {
      return .Reverse
    } else if state.currentIndex < index {
      return .Forward
    } else {
      return .None
    }
  }
  
  private func handleSelectEvent(index: Int) {
    let direction = directionForIndex(index)
    switch direction {
    case .Reverse:
      internalState = .Previous(
        index: state.currentIndex,
        upcomingIndex: index,
        offset: 0)
    case .Forward:
      internalState = .Next(
        index: state.currentIndex,
        upcomingIndex: index,
        offset: 0)
    default:
      break
    }
  }
  
  private func handleUpdateOffsetEvent(offset: CGFloat) {
    if offset > 0 {
      internalState = .Next(
        index: state.currentIndex,
        upcomingIndex: state.upcomingIndex,
        offset: offset)
    } else if offset < 0 {
      internalState = .Previous(
        index: state.currentIndex,
        upcomingIndex: state.upcomingIndex,
        offset: offset)
    }
  }
  
  private func handleDidMoveToIndexEvent(index: Int) {
    internalState = .Current(index: index)
  }
  
}
