import Foundation

class PagingStateMachine {
  
  var state: PagingState {
    return internalState
  }
  
  var internalState: PagingState = .Current(0) {
    didSet {
      if oldValue != internalState {
        for observer in self.stateObservers {
          observer(stateMachine: self, oldState: oldValue)
        }
      }
    }
  }
  
  var stateObservers: [(stateMachine: PagingStateMachine, oldState: PagingState) -> Void] = []
  var eventObservers: [(stateMachine: PagingStateMachine, event: PagingEvent) -> Void] = []
  
  func fire(event: PagingEvent) {
    switch event {
    case let .DidMove(index):
      handleDidMoveToIndexEvent(index)
    case let .WillMove(index):
      handleWillMoveToIndexEvent(index)
    case let .UpdateOffset(offset):
      handleUpdateOffsetEvent(offset)
    case let .Select(index, direction):
      handleSelectEvent(index, direction: direction)
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
  
  private func handleSelectEvent(index: Int, direction: PagingDirection) {
    switch direction {
    case .Reverse:
      internalState = .Previous(state.currentIndex, index, 0)
    case .Forward:
      internalState = .Next(state.currentIndex, index, 0)
    default:
      break
    }
  }
  
  private func handleUpdateOffsetEvent(offset: CGFloat) {
    if offset > 0 {
      internalState = .Next(state.currentIndex, state.upcomingIndex, offset)
    } else if offset < 0 {
      internalState = .Previous(state.currentIndex, state.upcomingIndex, offset)
    }
  }
  
  private func handleWillMoveToIndexEvent(index: Int) {
    if index > state.currentIndex {
      internalState = .Next(state.currentIndex, index, 0)
    } else if index < state.currentIndex {
      internalState = .Previous(state.currentIndex, index, 0)
    }
  }
  
  private func handleDidMoveToIndexEvent(index: Int) {
    internalState = .Current(index)
  }
  
}
