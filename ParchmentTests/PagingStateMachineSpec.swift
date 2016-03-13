import Foundation
import Quick
import Nimble
@testable import Parchment

class PagingStateMachineSpec: QuickSpec {
  
  override func spec() {
    
    describe("PagingStateMachineSpec") {
      
      var stateMachine: PagingStateMachine!
      
      beforeEach {
        stateMachine = PagingStateMachine()
      }
      
      it("has an initial state") {
        expect(stateMachine.state).to(equal(PagingState.Current(index: 0)))
      }
      
      it("returns the correct direction for upcoming index") {
        stateMachine.fire(.DidMove(index: 1))
        expect(stateMachine.directionForIndex(0)).to(equal(PagingDirection.Reverse))
        expect(stateMachine.directionForIndex(1)).to(equal(PagingDirection.None))
        expect(stateMachine.directionForIndex(2)).to(equal(PagingDirection.Forward))
      }
      
      it("handles updating the state when moving forward") {
        stateMachine.fire(.Update(offset: 0.5))
        let state: PagingState = .Next(index: 0, upcomingIndex: 0, offset: 0.5)
        expect(stateMachine.state).to(equal(state))
      }
      
      it("handles updating the state when moving backwards") {
        stateMachine.fire(.Update(offset: -0.5))
        let state: PagingState = .Previous(index: 0, upcomingIndex: 0, offset: -0.5)
        expect(stateMachine.state).to(equal(state))
      }
      
      it("doesn't update the state if offset is zero") {
        stateMachine.fire(.Update(offset: 0))
        let state: PagingState = .Current(index: 0)
        expect(stateMachine.state).to(equal(state))
      }
      
      it("handles selecting an upcoming index") {
        stateMachine.fire(.Select(index: 2))
        let state: PagingState = .Next(index: 0, upcomingIndex: 2, offset: 0)
        expect(stateMachine.state).to(equal(state))
      }
      
      it("handles selecting a previous index") {
        stateMachine.fire(.DidMove(index: 1))
        stateMachine.fire(.Select(index: 0))
        let state: PagingState = .Previous(index: 1, upcomingIndex: 0, offset: 0)
        expect(stateMachine.state).to(equal(state))
      }
      
      it("handles selecting a previous index") {
        stateMachine.fire(.DidMove(index: 1))
        stateMachine.fire(.Select(index: 0))
        let state: PagingState = .Previous(index: 1, upcomingIndex: 0, offset: 0)
        expect(stateMachine.state).to(equal(state))
      }
      
      it("handles the did move event") {
        stateMachine.fire(.DidMove(index: 4))
        let state: PagingState = .Current(index: 4)
        expect(stateMachine.state).to(equal(state))
      }
      
    }
    
  }
    
}
