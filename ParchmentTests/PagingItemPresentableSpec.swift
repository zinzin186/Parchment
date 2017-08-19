import Foundation
import Quick
import Nimble
@testable import Parchment

private struct PresentableItem: PagingItem, Equatable {
  let index: Int
  let width: CGFloat
}

private func ==(lhs: PresentableItem, rhs: PresentableItem) -> Bool {
  return lhs.index == rhs.index && lhs.width == rhs.width
}

struct Presentable: PagingItemsPresentable {
  
  private let items: [PresentableItem] = [
    PresentableItem(index: 0, width: 50),
    PresentableItem(index: 1, width: 100),
    PresentableItem(index: 2, width: 50),
    PresentableItem(index: 3, width: 100),
    PresentableItem(index: 4, width: 50),
    PresentableItem(index: 5, width: 100),
    PresentableItem(index: 6, width: 50),
    PresentableItem(index: 7, width: 100),
    PresentableItem(index: 8, width: 50)
  ]
  
  func widthForPagingItem<T: PagingItem>(_ pagingItem: T) -> CGFloat {
    guard let item = pagingItem as? PresentableItem else { return 0 }
    return item.width
  }
  
  func pagingItemBeforePagingItem<T: PagingItem>(_ pagingItem: T) -> T? {
    guard let index = items.index(of: pagingItem as! PresentableItem) else { return nil }
    if index > 0 {
      return items[index - 1] as? T
    }
    return nil
  }
  
  func pagingItemAfterPagingItem<T: PagingItem>(_ pagingItem: T) -> T? {
    guard let index = items.index(of: pagingItem as! PresentableItem) else { return nil }
    if index < items.count - 1 {
      return items[index + 1] as? T
    }
    return nil
  }
  
}

class PagingItemsSpec: QuickSpec {
  
  override func spec() {
    
    let presentable = Presentable()
    
    describe("PagingItems") {
      
      describe("itemsBefore:") {
        
        it("returns no items before the first item") {
          let items = presentable.itemsBefore([PresentableItem(index: 0, width: 50)], width: 150)
          expect(items.isEmpty).to(beTrue())
        }
        
        it("returns no items if the width is zero") {
          let items = presentable.itemsBefore([PresentableItem(index: 4, width: 50)], width: 0)
          expect(items.isEmpty).to(beTrue())
        }
        
        it("only returns the items that can fit within the provided width") {
          let items = presentable.itemsBefore([PresentableItem(index: 4, width: 50)], width: 200)
          expect(items.count).to(equal(3))
          expect(items[0]).to(equal(PresentableItem(index: 1, width: 100)))
          expect(items[1]).to(equal(PresentableItem(index: 2, width: 50)))
          expect(items[2]).to(equal(PresentableItem(index: 3, width: 100)))
        }
        
        it("stops when the data source returns nil") {
          let items = presentable.itemsBefore([PresentableItem(index: 1, width: 100)], width: 500)
          expect(items.count).to(equal(1))
          expect(items[0]).to(equal(PresentableItem(index: 0, width: 50)))
        }
        
      }
      
      describe("itemsAfter:") {
        
        it("returns no items after the last item") {
          let items = presentable.itemsAfter([PresentableItem(index: 8, width: 50)], width: 150)
          expect(items.isEmpty).to(beTrue())
        }
        
        it("returns no items if the width is zero") {
          let items = presentable.itemsAfter([PresentableItem(index: 4, width: 50)], width: 0)
          expect(items.isEmpty).to(beTrue())
        }
        
        it("only returns the items that can fit within the provided width") {
          let items = presentable.itemsAfter([PresentableItem(index: 4, width: 50)], width: 200)
          expect(items.count).to(equal(3))
          expect(items[0]).to(equal(PresentableItem(index: 5, width: 100)))
          expect(items[1]).to(equal(PresentableItem(index: 6, width: 50)))
          expect(items[2]).to(equal(PresentableItem(index: 7, width: 100)))
        }
        
        it("stops when the data source returns nil") {
          let items = presentable.itemsAfter([PresentableItem(index: 7, width: 100)], width: 500)
          expect(items.count).to(equal(1))
          expect(items[0]).to(equal(PresentableItem(index: 8, width: 50)))
        }
        
      }
      
      describe("visibleItems:") {
        
        it("includes items before and after + the initial item") {
          let items = presentable.visibleItems(PresentableItem(index: 4, width: 50), width: 50)
          expect(items.count).to(equal(3))
          expect(items[0]).to(equal(PresentableItem(index: 3, width: 100)))
          expect(items[1]).to(equal(PresentableItem(index: 4, width: 50)))
          expect(items[2]).to(equal(PresentableItem(index: 5, width: 100)))
        }
        
      }
      
      describe("widthFromItem:") {
        
        it("accumulates the correct width") {
          let items = [PresentableItem(index: 3, width: 100)]
          let width = presentable.widthFromItem(
            PresentableItem(index: 0, width: 50),
            items: items,
            itemSpacing: 50)
          expect(width).to(equal(350))
        }
        
        it("returns zero for items already in data structure") {
          let items = [PresentableItem(index: 1, width: 100), PresentableItem(index: 2, width: 50)]
          
          let firstItemWidth = presentable.widthFromItem(
            PresentableItem(index: 1, width: 100),
            items: items,
            itemSpacing: 0)
          
          let lastItemWidth = presentable.widthFromItem(
            PresentableItem(index: 2, width: 50),
            items: items,
            itemSpacing: 0)
          
          expect(firstItemWidth).to(equal(0))
          expect(lastItemWidth).to(equal(0))
        }
        
        it("returns zero when there no visible items") {
          let width = presentable.widthFromItem(
            PresentableItem(index: 0, width: 50),
            items: [],
            itemSpacing: 0)
          expect(width).to(equal(0))
        }
        
        
      }
     
      describe("diffWidth:") {
        
        it("returns correct width for removed items") {
          
          let from = [
            PresentableItem(index: 0, width: 50),
            PresentableItem(index: 1, width: 100)
          ]
          
          let to = [
            PresentableItem(index: 1, width: 100),
          ]
          
          let width = presentable.diffWidth(
            from: from,
            to: to,
            itemSpacing: 0)
          
          expect(width).to(equal(-50))
        }
        
        it("returns correct width for added items") {
          
          let from = [
            PresentableItem(index: 1, width: 100)
          ]
          
          let to = [
            PresentableItem(index: 0, width: 50),
            PresentableItem(index: 1, width: 100)
          ]
          
          let width = presentable.diffWidth(
            from: from,
            to: to,
            itemSpacing: 0)
          
          expect(width).to(equal(50))
        }
        
      }
      
    }
    
  }

}
