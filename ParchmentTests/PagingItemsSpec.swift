import Foundation
import Quick
import Nimble
@testable import Parchment

struct Options: PagingOptions {
  let menuItemSize: PagingMenuItemSize = .Fixed(width: 50, height: 50)
}

class DataSource: PagingDataSource {
  
  let items: [IndexPagingItem] = [
    IndexPagingItem(index: 0),
    IndexPagingItem(index: 1),
    IndexPagingItem(index: 2),
    IndexPagingItem(index: 3),
    IndexPagingItem(index: 4),
    IndexPagingItem(index: 5),
    IndexPagingItem(index: 6),
    IndexPagingItem(index: 7),
    IndexPagingItem(index: 8)
  ]
  
  func initialPagingItem() -> PagingItem? {
    return items.first
  }
  
  func pagingItemBeforePagingItem(pagingItem: PagingItem) -> PagingItem? {
    guard let index = items.indexOf({ $0.isEqual(pagingItem) }) else { return nil }
    if index > 0 {
      return items[index - 1]
    }
    return nil
  }
  
  func pagingItemAfterPagingItem(pagingItem: PagingItem) -> PagingItem? {
    guard let index = items.indexOf({ $0.isEqual(pagingItem) }) else { return nil }
    if index < items.count - 1 {
      return items[index + 1]
    }
    return nil
  }
  
  func viewControllerForPagingItem(pagingItem: PagingItem) -> UIViewController {
    return UIViewController()
  }
  
}

class PagingItemsSpec: QuickSpec {
  
  override func spec() {
    
    let options = Options()
    let dataSource = DataSource()
    
    describe("PagingItems") {
      
      describe("itemsBefore:") {
        
        it("returns no items before the last item") {
          let items = itemsBefore([IndexPagingItem(index: 0)],
                                  width: 150,
                                  dataSource: dataSource,
                                  options: options)
          expect(items.isEmpty).to(beTrue())
        }
        
        it("returns no items if the width is zero") {
          let items = itemsBefore([IndexPagingItem(index: 4)],
                                  width: 0,
                                  dataSource: dataSource,
                                  options: options)
          expect(items.isEmpty).to(beTrue())
        }
        
        it("only returns the items that can fit within the provided width") {
          let items: [IndexPagingItem] = itemsBefore([IndexPagingItem(index: 4)],
                                                     width: 150,
                                                     dataSource: dataSource,
                                                     options: options)
          expect(items.count).to(equal(3))
          expect(items[0]).to(equal(IndexPagingItem(index: 1)))
          expect(items[1]).to(equal(IndexPagingItem(index: 2)))
          expect(items[2]).to(equal(IndexPagingItem(index: 3)))
        }
        
        it("stops when the data source returns nil") {
          let items: [IndexPagingItem] = itemsBefore([IndexPagingItem(index: 1)],
                                                     width: 500,
                                                     dataSource: dataSource,
                                                     options: options)
          expect(items.count).to(equal(1))
          expect(items[0]).to(equal(IndexPagingItem(index: 0)))
        }
        
      }
      
      describe("itemsAfter:") {
        
        it("returns no items after the first item") {
          let items = itemsAfter([IndexPagingItem(index: 8)],
                                 width: 150,
                                 dataSource: dataSource,
                                 options: options)
          expect(items.isEmpty).to(beTrue())
        }
        
        it("returns no items if the width is zero") {
          let items = itemsAfter([IndexPagingItem(index: 4)],
                                  width: 0,
                                  dataSource: dataSource,
                                  options: options)
          expect(items.isEmpty).to(beTrue())
        }
        
        it("only returns the items that can fit within the provided width") {
          let items: [IndexPagingItem] = itemsAfter([IndexPagingItem(index: 4)],
                                                     width: 150,
                                                     dataSource: dataSource,
                                                     options: options)
          expect(items.count).to(equal(3))
          expect(items[0]).to(equal(IndexPagingItem(index: 5)))
          expect(items[1]).to(equal(IndexPagingItem(index: 6)))
          expect(items[2]).to(equal(IndexPagingItem(index: 7)))
        }
        
        it("stops when the data source returns nil") {
          let items: [IndexPagingItem] = itemsAfter([IndexPagingItem(index: 7)],
                                                     width: 500,
                                                     dataSource: dataSource,
                                                     options: options)
          expect(items.count).to(equal(1))
          expect(items[0]).to(equal(IndexPagingItem(index: 8)))
        }
        
      }
      
      describe("visibleItems:") {
        
        it("includes items before and after + the initial item") {
          let items: [IndexPagingItem] = visibleItems(IndexPagingItem(index: 4),
                                                      width: 50,
                                                      dataSource: dataSource,
                                                      options: options)
          expect(items.count).to(equal(3))
          expect(items[0]).to(equal(IndexPagingItem(index: 3)))
          expect(items[1]).to(equal(IndexPagingItem(index: 4)))
          expect(items[2]).to(equal(IndexPagingItem(index: 5)))
        }
        
      }
      
      describe("widthFromPagingItem:") {
        
        it("accumulates the correct width") {
          let items = [IndexPagingItem(index: 3)]
          let dataStructure = PagingDataStructure<IndexPagingItem>(visibleItems: items)
          let width = widthFromItem(IndexPagingItem(index: 0),
                                    dataStructure: dataStructure,
                                    dataSource: dataSource,
                                    options: options)
          expect(width).to(equal(150))
        }
        
        it("returns zero for items already in data structure") {
          let items = [IndexPagingItem(index: 1), IndexPagingItem(index: 2)]
          let dataStructure = PagingDataStructure<IndexPagingItem>(visibleItems: items)
          
          let firstItemWidth = widthFromItem(IndexPagingItem(index: 1),
                                             dataStructure: dataStructure,
                                             dataSource: dataSource,
                                             options: options)
          
          let lastItemWidth = widthFromItem(IndexPagingItem(index: 2),
                                            dataStructure: dataStructure,
                                            dataSource: dataSource,
                                            options: options)
          
          expect(firstItemWidth).to(equal(0))
          expect(lastItemWidth).to(equal(0))
        }
        
      }
     
      describe("diffWidth:") {
        
        it("returns correct width for removed items") {
          
          let from = PagingDataStructure(visibleItems: [
            IndexPagingItem(index: 0),
            IndexPagingItem(index: 1)
          ])
          
          let to = PagingDataStructure(visibleItems: [
            IndexPagingItem(index: 1),
          ])
          
          let width = diffWidth(
            from: from,
            to: to,
            dataSource: dataSource,
            options: options)
          
          expect(width).to(equal(-50))
        }
        
        it("returns correct width for added items") {
          
          let from = PagingDataStructure(visibleItems: [
            IndexPagingItem(index: 1)
          ])
          
          let to = PagingDataStructure(visibleItems: [
            IndexPagingItem(index: 0),
            IndexPagingItem(index: 1)
          ])
          
          let width = diffWidth(
            from: from,
            to: to,
            dataSource: dataSource,
            options: options)
          
          expect(width).to(equal(50))
        }
        
      }
      
    }
    
  }

}
