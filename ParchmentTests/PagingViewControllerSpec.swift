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

class PagingViewControllerSpec: QuickSpec {
  
  override func spec() {
    
    xdescribe("PagingViewController") {
      
      describe("reloading items") {
        
        let dataSource = DataSource()
        var viewController: PagingViewController<Item>!
        
        beforeEach {
          viewController = PagingViewController()
          viewController.menuItemSize = .fixed(width: 100, height: 50)
          viewController.infiniteDataSource = dataSource
          
          UIApplication.shared.keyWindow!.rootViewController = viewController
          let _ = viewController.view
          
          viewController.collectionView.bounds = CGRect(x: 0, y: 0, width: 1000, height: 50)
        }
        
        it("reloadItems: at begining") {
          viewController.select(pagingItem: Item(index: 0))
          let items = viewController.collectionView.numberOfItems(inSection: 0)
          expect(items).to(equal(21))
        }
        
        it("reloadItems: at center") {
          viewController.select(pagingItem: Item(index: 20))
          let items = viewController.collectionView.numberOfItems(inSection: 0)
          expect(items).to(equal(21))
        }
        
        it("reloadItems: at end") {
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

