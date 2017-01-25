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
      
      let defaultTransition = PagingTransition(contentOffset: .zero, distance: 0)
      
      describe("Scrolling") {
        
        it("returns the current paging item") {
          let state: PagingState = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            progress: 0,
            transition: defaultTransition)
          expect(state.currentPagingItem).to(equal(Item(index: 0)))
        }
        
        it("returns the correct progress") {
          let state: PagingState = .scrolling(
            pagingItem: Item(index: 0),
            upcomingPagingItem: Item(index: 1),
            progress: 0.5,
            transition: defaultTransition)
          expect(state.progress).to(equal(0.5))
        }
        
        describe("has an upcoming paging item") {
          
          it("returns the correct upcoming paging item") {
            let state: PagingState = .scrolling(
              pagingItem: Item(index: 0),
              upcomingPagingItem: Item(index: 1),
              progress: 0,
              transition: defaultTransition)
            expect(state.upcomingPagingItem).to(equal(Item(index: 1)))
          }
          
          describe("visuallySelectedPagingItem") {
          
            describe("progress is larger then 0.5") {
              it("returns the upcoming paging item as the visually selected item") {
                let state: PagingState = .scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: Item(index: 1),
                  progress: 0.6,
                  transition: defaultTransition)
                expect(state.visuallySelectedPagingItem).to(equal(Item(index: 1)))
              }
            }
            
            describe("progress is smaller then 0.5") {
              it("returns the current paging item as the visually selected item") {
                let state: PagingState = .scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: Item(index: 1),
                  progress: 0.3,
                  transition: defaultTransition)
                expect(state.visuallySelectedPagingItem).to(equal(Item(index: 0)))
              }
            }
            
          }
          
        }
        
        describe("does not have an upcoming paging item") {
          
          it("returns nil for upcoming paging item") {
            let state: PagingState = .scrolling(
              pagingItem: Item(index: 0),
              upcomingPagingItem: nil,
              progress: 0,
              transition: defaultTransition)
            expect(state.upcomingPagingItem).to(beNil())
          }
          
          describe("visuallySelectedPagingItem") {
            
            describe("progress is larger then 0.5") {
              it("returns the current paging item as the visually selected item") {
                let state: PagingState = .scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: nil,
                  progress: 0.6,
                  transition: defaultTransition)
                expect(state.visuallySelectedPagingItem).to(equal(Item(index: 0)))
              }
            }
            
            describe("progress is smaller then 0.5") {
              it("returns the current paging item as the visually selected item") {
                let state: PagingState = .scrolling(
                  pagingItem: Item(index: 0),
                  upcomingPagingItem: nil,
                  progress: 0.3,
                  transition: defaultTransition)
                expect(state.visuallySelectedPagingItem).to(equal(Item(index: 0)))
              }
            }
            
          }
        }
        
      }
      
      describe("Selected") {
        
        let state: PagingState = .selected(pagingItem: Item(index: 0))
        
        it("returns the current paging item") {
          expect(state.currentPagingItem).to(equal(Item(index: 0)))
        }
        
        it("returns nil for the upcoming paging item") {
          expect(state.upcomingPagingItem).to(beNil())
        }
        
        it("returns zero for the progress") {
          expect(state.progress).to(equal(0))
        }
        
        it("returns the current paging item as the visually selected item") {
          expect(state.visuallySelectedPagingItem).to(equal(Item(index: 0)))
        }
        
      }
    
    }
    
  }
  
}
