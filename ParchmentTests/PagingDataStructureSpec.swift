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

class PagingDataStructureSpec: QuickSpec {
  
  override func spec() {
    
    describe("PagingDataStructure") {
      
      var dataStructure: PagingDataStructure<Item>!
      
      beforeEach {
        dataStructure = PagingDataStructure(visibleItems: [
          Item(index: 0),
          Item(index: 1),
          Item(index: 2)
        ], totalWidth: 0)
      }
      
      describe("indexPathForPagingItem:") {
        
        it("returns the index path if the paging item exists") {
          let indexPath = dataStructure.indexPathForPagingItem(Item(index: 0))!
          expect(indexPath.item).to(equal(0))
        }
        
        it("returns nil if paging item is not in visible items") {
          let indexPath = dataStructure.indexPathForPagingItem(Item(index: -1))
          expect(indexPath).to(beNil())
        }
        
      }
      
      describe("pagingItemForIndexPath:") {
        it("returns the paging item for a given index path") {
          let indexPath = IndexPath(item: 0, section: 0)
          let pagingItem = dataStructure.pagingItemForIndexPath(indexPath)
          expect(pagingItem).to(equal(Item(index: 0)))
        }
      }
      
      describe("directionForIndexPath:currentPagingItem:") {
        
        describe("has a index path for the current paging item") {

          describe("upcoming index path is larger than current index path") {
            it("returns forward") {
              let indexPath = IndexPath(item: 1, section: 0)
              let currentPagingItem = Item(index: 0)
              let direction = dataStructure.directionForIndexPath(indexPath, currentPagingItem: currentPagingItem)
              expect(direction).to(equal(PagingDirection.forward))
            }
          }
          
          describe("upcoming index path is smaller than current index path") {
            it("returns reverse") {
              let indexPath = IndexPath(item: 0, section: 0)
              let currentPagingItem = Item(index: 1)
              let direction = dataStructure.directionForIndexPath(indexPath, currentPagingItem: currentPagingItem)
              expect(direction).to(equal(PagingDirection.reverse))
            }
          }
          
        }
        
        describe("does not have a index path for the current item") {
          it("returns none") {
            let indexPath = IndexPath(item: 0, section: 0)
            let currentPagingItem = Item(index: -1)
            let direction = dataStructure.directionForIndexPath(indexPath, currentPagingItem: currentPagingItem)
            expect(direction).to(equal(PagingDirection.none))
          }
        }
        
      }
      
    }
    
  }
  
}
