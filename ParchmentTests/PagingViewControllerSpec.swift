import Foundation
import Quick
import Nimble
import UIKit
@testable import Parchment

class DataSource: PagingViewControllerInfiniteDataSource {
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemAfterPagingItem: T) -> T? {
    guard let item = pagingItemAfterPagingItem as? Item else { return nil }
    
    if (item.index < 50) {
      return Item(index: item.index + 1) as? T
    }
    return nil
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemBeforePagingItem: T) -> T? {
    guard let item = pagingItemBeforePagingItem as? Item else { return nil }
    
    if (item.index > 0) {
      return Item(index: item.index - 1) as? T
    }
    return nil
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForPagingItem: T) -> UIViewController {
    return UIViewController()
  }
  
}

class DeinitPagingViewController: PagingViewController<PagingIndexItem> {
  var deinitCalled: (() -> Void)?
  deinit { deinitCalled?() }
}

class DeinitFixedPagingViewController: FixedPagingViewController {
  var deinitCalled: (() -> Void)?
  deinit { deinitCalled?() }
}

class ReloadingDataSource: PagingViewControllerDataSource {
  var items: [PagingIndexItem] = []
  
  func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int {
    return items.count
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
    return UIViewController()
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
    return items[index] as! T
  }
}

class PagingViewControllerSpec: QuickSpec {
  
  override func spec() {
    
    describe("PagingViewController") {
      
      describe("reloading data") {
        
        let dataSource = ReloadingDataSource()
        var viewController: PagingViewController<PagingIndexItem>!
        
        beforeEach {
          dataSource.items = [
            PagingIndexItem(index: 0, title: "First"),
            PagingIndexItem(index: 1, title: "Second")
          ]
          
          viewController = PagingViewController()
          viewController.menuItemSize = .fixed(width: 100, height: 50)
          viewController.dataSource = dataSource
          
          UIApplication.shared.keyWindow!.rootViewController = viewController
          let _ = viewController.view
          
          viewController.collectionView.bounds = CGRect(x: 0, y: 0, width: 1000, height: 50)
          viewController.viewDidLayoutSubviews()
        }
        
        it("reloads data around item") {
          let first = PagingIndexItem(index: 2, title: "Third")
          let third = PagingIndexItem(index: 3, title: "Fourth")
          dataSource.items = [first, third]
          viewController.reloadData(around: first)
          
          let cell1 = viewController.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! PagingTitleCell
          let cell2 = viewController.collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as! PagingTitleCell
          
          expect(cell1.titleLabel.text).to(equal("Third"))
          expect(cell2.titleLabel.text).to(equal("Fourth"))
        }
        
        it("selects previously selected item when reloading data") {
          let first = PagingIndexItem(index: 0, title: "First")
          let second = PagingIndexItem(index: 1, title: "Second")
          let third = PagingIndexItem(index: 2, title: "Third")
          
          viewController.select(index: 1)
          dataSource.items = [first, second, third]
          viewController.reloadData()
          
          let cell1 = viewController.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! PagingTitleCell
          let cell2 = viewController.collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as! PagingTitleCell
          let cell3 = viewController.collectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as! PagingTitleCell
          
          expect(cell1.titleLabel.text).to(equal("First"))
          expect(cell2.titleLabel.text).to(equal("Second"))
          expect(cell3.titleLabel.text).to(equal("Third"))
          expect(viewController.state).to(equal(PagingState.selected(pagingItem: second)))
        }
        
        it("selects the first item when reloading data with all new items") {
          let third = PagingIndexItem(index: 2, title: "Third")
          let fourth = PagingIndexItem(index: 3, title: "Fourth")
          
          viewController.select(index: 1)
          dataSource.items = [third, fourth]
          viewController.reloadData()
          
          let cell1 = viewController.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! PagingTitleCell
          let cell2 = viewController.collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as! PagingTitleCell
          
          expect(cell1.titleLabel.text).to(equal("Third"))
          expect(cell2.titleLabel.text).to(equal("Fourth"))
          expect(viewController.state).to(equal(PagingState.selected(pagingItem: third)))
        }
        
        it("display an empty view after reloading data with no items") {
          dataSource.items = []
          viewController.reloadData()
          
          expect(viewController.pageViewController.scrollView.subviews).to(beEmpty())
          expect(viewController.collectionView.numberOfItems(inSection: 0)).to(equal(0))
        }
      }
      
      describe("selecting items") {
        
        let dataSource = DataSource()
        var viewController: PagingViewController<Item>!
        
        beforeEach {
          viewController = PagingViewController()
          viewController.menuItemSize = .fixed(width: 100, height: 50)
          viewController.infiniteDataSource = dataSource
          
          UIApplication.shared.keyWindow!.rootViewController = viewController
          let _ = viewController.view
          
          viewController.collectionView.bounds = CGRect(x: 0, y: 0, width: 1000, height: 50)
          viewController.viewDidLayoutSubviews()
        }
        
        it("selecting the first item generates enough items") {
          viewController.select(pagingItem: Item(index: 0))
          let items = viewController.collectionView.numberOfItems(inSection: 0)
          expect(items).to(equal(21))
        }
        
        it("selecting the center item generates enough items") {
          viewController.select(pagingItem: Item(index: 20))
          let items = viewController.collectionView.numberOfItems(inSection: 0)
          expect(items).to(equal(21))
        }
        
        it("selecting the last item generates enough items") {
          viewController.select(pagingItem: Item(index: 50))
          let items = viewController.collectionView.numberOfItems(inSection: 0)
          expect(items).to(equal(21))
        }
        
      }
      
      describe("retain cycles") {
      
        it("deinits PagingViewController") {
          var instance: DeinitPagingViewController? = DeinitPagingViewController()
          waitUntil { done in
            instance?.deinitCalled = {
              done()
            }
            DispatchQueue.global(qos: .background).async {
              instance = nil
            }
          }
        }
        
        it("deinits FixedPagingViewController") {
          let viewController = UIViewController()
          var instance: DeinitFixedPagingViewController? = DeinitFixedPagingViewController(viewControllers: [viewController])
          waitUntil { done in
            instance?.deinitCalled = {
              done()
            }
            DispatchQueue.global(qos: .background).async {
              instance = nil
            }
          }
        }
      }
    }
  }
}

