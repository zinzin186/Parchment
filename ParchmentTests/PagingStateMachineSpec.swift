import Foundation
import Quick
import Nimble
@testable import Parchment

class PagingStateMachineSpec: QuickSpec {
  
  override func spec() {
    
    describe("PagingStateMachine") {
      
      var stateMachine: PagingStateMachine!
      
      beforeEach {
        stateMachine = PagingStateMachine()
      }
      
      it("has an initial state") {
        expect(stateMachine.state).to(equal(PagingState.Current(0)))
      }
      
    }
    
  }
    
}
