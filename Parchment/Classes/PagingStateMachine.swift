import Foundation

protocol PagingStateMachineDelegate: class {
  func pagingStateMachine<T>(_ pagingStateMachine: PagingStateMachine<T>, pagingItemBeforePagingItem: T) -> T?
  func pagingStateMachine<T>(_ pagingStateMachine: PagingStateMachine<T>, pagingItemAfterPagingItem: T) -> T?
  func pagingStateMachine<T>(_ pagingStateMachine: PagingStateMachine<T>, transitionFromPagingItem: T, toPagingItem: T?) -> PagingTransition
}

class PagingStateMachine<T: PagingItem> where T: Equatable {
  
  weak var delegate: PagingStateMachineDelegate?
  
  var didSelectPagingItem: ((T, PagingDirection, Bool) -> Void)?
  var didChangeState: ((PagingState<T>, PagingState<T>, PagingEvent<T>?) -> Void)?
  
  fileprivate(set) var state: PagingState<T>
  
  init(initialState: PagingState<T>) {
    self.state = initialState
  }
  
  func fire(_ event: PagingEvent<T>) {
    switch event {
    case let .reload(contentOffset):
      handleReloadEvent(contentOffset: contentOffset, event)
    case let .scroll(progress):
      handleScrollEvent(
        event,
        progress: progress)
    case let .select(pagingItem, direction, animated):
      handleSelectEvent(
        event,
        selectedPagingItem: pagingItem,
        direction: direction,
        animated: animated)
    case .finishScrolling:
      handleFinishScrollingEvent(event)
    case .transitionSize:
      handleTransitionSizeEvent(event)
    case .cancelScrolling:
      handleCancelScrollingEvent(event)
    }
  }
  
  fileprivate func handleReloadEvent(contentOffset: CGPoint, _ event: PagingEvent<T>) {
    let oldState = state
    if case let .scrolling(pagingItem, upcomingPagingItem, progress, _, distance) = state {
     if let transition = delegate?.pagingStateMachine(self, transitionFromPagingItem: pagingItem, toPagingItem: upcomingPagingItem) {
      
      let newContentOffset = CGPoint(
        x: contentOffset.x - (distance - transition.distance),
        y: contentOffset.y)
      
      state = .scrolling(
        pagingItem: pagingItem,
        upcomingPagingItem: upcomingPagingItem,
        progress: progress,
        initialContentOffset: newContentOffset,
        distance: distance)
      
      didChangeState?(oldState, state, event)
      }
    }
  }
  
  fileprivate func handleScrollEvent(_ event: PagingEvent<T>, progress: CGFloat) {
    
    let oldState = state
    
    switch state {
    case let .scrolling(pagingItem, upcomingPagingItem, oldProgress, initialContentOffset, distance):
      if oldProgress < 0 && progress > 0 {
        state = .selected(pagingItem: pagingItem)
      } else if oldProgress > 0 && progress < 0 {
        state = .selected(pagingItem: pagingItem)
      } else if progress == 0 {
        state = .selected(pagingItem: pagingItem)
      } else {
        state = .scrolling(
          pagingItem: pagingItem,
          upcomingPagingItem: upcomingPagingItem,
          progress: progress,
          initialContentOffset: initialContentOffset,
          distance: distance)
        
        didChangeState?(oldState, state, event)
      }
    case let .selected(pagingItem):
      if progress > 0 {
        let upcomingPagingItem = delegate?.pagingStateMachine(self, pagingItemAfterPagingItem: pagingItem)
        
        if let transition = delegate?.pagingStateMachine(self,
          transitionFromPagingItem: pagingItem,
          toPagingItem: upcomingPagingItem) {

          state = .scrolling(
            pagingItem: pagingItem,
            upcomingPagingItem: upcomingPagingItem,
            progress: progress,
            initialContentOffset: transition.contentOffset,
            distance: transition.distance)
          
          didChangeState?(oldState, state, event)
        }
      } else if progress < 0 {
        let upcomingPagingItem = delegate?.pagingStateMachine(self, pagingItemBeforePagingItem: pagingItem)
        
        if let transition = delegate?.pagingStateMachine(self,
          transitionFromPagingItem: pagingItem,
          toPagingItem: upcomingPagingItem) {
          
          state = .scrolling(
            pagingItem: pagingItem,
            upcomingPagingItem: upcomingPagingItem,
            progress: progress,
            initialContentOffset: transition.contentOffset,
            distance: transition.distance)
        }
      }
      
      didChangeState?(oldState, state, event)
    }
    
  }
  
  fileprivate func handleSelectEvent(_ event: PagingEvent<T>, selectedPagingItem: T, direction: PagingDirection, animated: Bool) {
    let oldState = state
    
    if selectedPagingItem != state.currentPagingItem {
      if case .selected = state {
        if let transition = delegate?.pagingStateMachine(self,
          transitionFromPagingItem: state.currentPagingItem,
          toPagingItem: selectedPagingItem) {
          
          state = .scrolling(
            pagingItem: state.currentPagingItem,
            upcomingPagingItem: selectedPagingItem,
            progress: 0,
            initialContentOffset: transition.contentOffset,
            distance: transition.distance)
          
          didSelectPagingItem?(selectedPagingItem, direction, animated)
          didChangeState?(oldState, state, event)
        }
      }
    }
  }
  
  fileprivate func handleFinishScrollingEvent(_ event: PagingEvent<T>) {
    let oldState = state
    switch state {
    case let .scrolling(currentPagingItem, upcomingPagingItem, _, _, _):
      state = .selected(pagingItem: upcomingPagingItem ?? currentPagingItem)
      didChangeState?(oldState, state, event)
    case .selected:
      break
    }
  }
  
  fileprivate func handleTransitionSizeEvent(_ event: PagingEvent<T>) {
    let oldState = state
    switch state {
    case let .scrolling(currentPagingItem, _, _, _, _):
      state = .selected(pagingItem: currentPagingItem)
      didChangeState?(oldState, state, event)
    case .selected:
      break
    }
  }
  
  fileprivate func handleCancelScrollingEvent(_ event: PagingEvent<T>) {
    let oldState = state
    switch state {
    case let .scrolling(currentPagingItem, _, _, _, _):
      state = .selected(pagingItem: currentPagingItem)
      didChangeState?(oldState, state, event)
    case .selected:
      break
    }
  }
  
}
