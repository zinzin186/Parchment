import Foundation
import Quick
import Nimble
@testable import Parchment

private struct Item: PagingItem, Equatable {
  let index: Int
}

private func ==(lhs: Item, rhs: Item) -> Bool {
  return lhs.index == rhs.index
}

class PagingStateSpec: QuickSpec {
  
  override func spec() {
    
    describe("PagingState") {
      
      describe("Scrolling") {
        
        it("returns the current paging item") {
          let state: PagingState = .Scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            offset: 0)
          expect(state.currentPagingItem).to(equal(Item(index: 0)))
        }
        
        it("returns the correct offset") {
          let state: PagingState = .Scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            offset: 0.5)
          expect(state.offset).to(equal(0.5))
        }
        
        describe("has an upcoming paging item") {
          
          it("returns the correct upcoming paging item") {
            let state: PagingState = .Scrolling(
              pagingItem: Item(index: 0),
              upcomingPagingItem: Item(index: 1),
              offset: 0)
            expect(state.upcomingPagingItem).to(equal(Item(index: 1)))
          }
          
          describe("visuallySelectedPagingItem") {
          
            describe("offset is larger then 0.5") {
              it("returns the upcoming paging item as the visually selected item") {
                let state: PagingState = .Scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: Item(index: 1),
                  offset: 0.6)
                expect(state.visuallySelectedPagingItem).to(equal(Item(index: 1)))
              }
            }
            
            describe("offset is smaller then 0.5") {
              it("returns the current paging item as the visually selected item") {
                let state: PagingState = .Scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: Item(index: 1),
                  offset: 0.3)
                expect(state.visuallySelectedPagingItem).to(equal(Item(index: 0)))
              }
            }
            
          }
          
        }
        
        describe("does not have an upcoming paging item") {
          
          it("returns nil for upcoming paging item") {
            let state: PagingState = .Scrolling(
              pagingItem: Item(index: 0),
              upcomingPagingItem: nil,
              offset: 0)
            expect(state.upcomingPagingItem).to(beNil())
          }
          
          describe("visuallySelectedPagingItem") {
            
            describe("offset is larger then 0.5") {
              it("returns the current paging item as the visually selected item") {
                let state: PagingState = .Scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: nil,
                  offset: 0.6)
                expect(state.visuallySelectedPagingItem).to(equal(Item(index: 0)))
              }
            }
            
            describe("offset is smaller then 0.5") {
              it("returns the current paging item as the visually selected item") {
                let state: PagingState = .Scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: nil,
                  offset: 0.3)
                expect(state.visuallySelectedPagingItem).to(equal(Item(index: 0)))
              }
            }
            
          }
        }
        
      }
      
      describe("Selected") {
        
        let state: PagingState = .Selected(pagingItem: Item(index: 0))
        
        it("returns the current paging item") {
          expect(state.currentPagingItem).to(equal(Item(index: 0)))
        }
        
        it("returns nil for the upcoming paging item") {
          expect(state.upcomingPagingItem).to(beNil())
        }
        
        it("returns zero for the offset") {
          expect(state.offset).to(equal(0))
        }
        
        it("returns the current paging item as the visually selected item") {
          expect(state.visuallySelectedPagingItem).to(equal(Item(index: 0)))
        }
        
      }
    
    }
    
  }
  
}
