import Foundation
import Quick
import Nimble
@testable import Parchment

struct IndexPagingItem: PagingItem, Equatable {
  let index: Int
  
  func isEqual(pagingItem: PagingItem) -> Bool {
    let indexPagingItem = pagingItem as! IndexPagingItem
    return index == indexPagingItem.index
  }
}

func ==(lhs: IndexPagingItem, rhs: IndexPagingItem) -> Bool {
  return lhs.isEqual(rhs)
}

class PagingStateMachineSpec: QuickSpec {
  
  override func spec() {
    
    describe("PagingStateMachineSpec") {
      
      var stateMachine: PagingStateMachine<IndexPagingItem>!
      
      beforeEach {
        stateMachine = PagingStateMachine(initialPagingItem: IndexPagingItem(index: 0))
      }
      
      it("has correct initial paging item") {
        let state: PagingState = .Current(pagingItem: IndexPagingItem(index: 0))
        expect(stateMachine.state).to(equal(state))
      }
      
      it("updates the state when the offset changes") {
        let pagingItem = IndexPagingItem(index: 0)
        let state: PagingState = .Next(pagingItem: pagingItem, upcomingPagingItem: pagingItem, offset: 0.5)
        
        stateMachine.fire(.Update(offset: 0.5))
        expect(stateMachine.state).to(equal(state))
      }

      it("doesn't update the state if offset is zero") {
        stateMachine.fire(.Update(offset: 0))
        let state: PagingState = .Current(pagingItem: IndexPagingItem(index: 0))
        expect(stateMachine.state).to(equal(state))
      }
      
      it("sets the correct state when dragging forward") {
        stateMachine.fire(.DidBeginDragging(upcomingPagingItem: IndexPagingItem(index: 2), direction: .Forward))
        let state: PagingState = .Next(pagingItem: IndexPagingItem(index: 0), upcomingPagingItem: IndexPagingItem(index: 2), offset: 0)
        expect(stateMachine.state).to(equal(state))
      }
      
      it("sets the correct state when dragging backwards") {
        stateMachine = PagingStateMachine(initialPagingItem: IndexPagingItem(index: 2))
        stateMachine.fire(.DidBeginDragging(upcomingPagingItem: IndexPagingItem(index: 0), direction: .Reverse))
        let state: PagingState = .Previous(pagingItem: IndexPagingItem(index: 2), upcomingPagingItem: IndexPagingItem(index: 0), offset: 0)
        expect(stateMachine.state).to(equal(state))
      }
      
      it("maintains the offset when beginning to drag") {
        stateMachine.fire(.Update(offset: 0.5))
        stateMachine.fire(.DidBeginDragging(upcomingPagingItem: IndexPagingItem(index: 1), direction: .Forward))
        let state: PagingState = .Next(pagingItem: IndexPagingItem(index: 0), upcomingPagingItem: IndexPagingItem(index: 1), offset: 0.5)
        expect(stateMachine.state).to(equal(state))
      }
      
      it("handles selecting an upcoming index") {
        stateMachine.fire(.Select(pagingItem: IndexPagingItem(index: 1), direction: .Forward))
        let state: PagingState = .Next(pagingItem: IndexPagingItem(index: 0), upcomingPagingItem: IndexPagingItem(index: 1), offset: 0)
        expect(stateMachine.state).to(equal(state))
      }
      
      it("handles selecting an previous index") {
        stateMachine = PagingStateMachine(initialPagingItem: IndexPagingItem(index: 1))
        stateMachine.fire(.Select(pagingItem: IndexPagingItem(index: 0), direction: .Reverse))
        let state: PagingState = .Previous(pagingItem: IndexPagingItem(index: 1), upcomingPagingItem: IndexPagingItem(index: 0), offset: 0)
        expect(stateMachine.state).to(equal(state))
      }
      
      it("handles the did move event") {
        stateMachine.fire(.DidMove(pagingItem: IndexPagingItem(index: 4)))
        let state: PagingState = .Current(pagingItem: IndexPagingItem(index: 4))
        expect(stateMachine.state).to(equal(state))
      }
      
    }
    
  }
    
}
