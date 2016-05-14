import Foundation

protocol PagingStateMachineDelegate: class {
  func pagingStateMachine<T>(pagingStateMachine: PagingStateMachine<T>, pagingItemBeforePagingItem: T) -> T?
  func pagingStateMachine<T>(pagingStateMachine: PagingStateMachine<T>, pagingItemAfterPagingItem: T) -> T?
}

class PagingStateMachine<T: PagingItem where T: Equatable> {
  
  weak var delegate: PagingStateMachineDelegate?
  
  var didSelectPagingItem: ((T, PagingDirection) -> Void)?
  var didChangeState: (PagingState<T> -> Void)?
  
  private(set) var state: PagingState<T> {
    didSet {
      didChangeState?(state)
    }
  }
  
  init(initialState: PagingState<T>) {
    self.state = initialState
  }
  
  func fire(event: PagingEvent<T>) {
    switch event {
    case let .Scroll(offset):
      handleScrollEvent(offset)
    case let .Select(pagingItem, direction):
      handleSelectEvent(pagingItem, direction: direction)
    case .FinishScrolling:
      handleFinishScrollingEvent()
    }
  }
  
  private func handleScrollEvent(offset: CGFloat) {
    switch state {
    case let .Scrolling(pagingItem, upcomingPagingItem, oldOffset):
      if oldOffset < 0 && offset > 0 {
        state = .Selected(pagingItem: pagingItem)
      } else if oldOffset > 0 && offset < 0 {
        state = .Selected(pagingItem: pagingItem)
      } else if offset == 0 {
        state = .Selected(pagingItem: pagingItem)
      } else {
        state = .Scrolling(
          pagingItem: pagingItem,
          upcomingPagingItem: upcomingPagingItem,
          offset: offset)
      }
    case let .Selected(pagingItem):
      if offset > 0 {
        state = .Scrolling(
          pagingItem: pagingItem,
          upcomingPagingItem: delegate?.pagingStateMachine(self,
            pagingItemAfterPagingItem: pagingItem),
          offset: offset)
      } else if offset < 0 {
        state = .Scrolling(
          pagingItem: pagingItem,
          upcomingPagingItem: delegate?.pagingStateMachine(self,
            pagingItemBeforePagingItem: pagingItem),
          offset: offset)
      }
    }
  }
  
  private func handleSelectEvent(selectedPagingItem: T, direction: PagingDirection) {
    if selectedPagingItem != state.currentPagingItem {
      state = .Scrolling(
        pagingItem: state.currentPagingItem,
        upcomingPagingItem: selectedPagingItem,
        offset: 0)
      didSelectPagingItem?(selectedPagingItem, direction)
    }
  }
  
  private func handleFinishScrollingEvent() {
    switch state {
    case let .Scrolling(currentPagingItem, upcomingPagingItem, _):
      state = .Selected(pagingItem: upcomingPagingItem ?? currentPagingItem)
    case .Selected:
      break
    }
  }
  
}
