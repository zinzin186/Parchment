import Foundation
import Quick
import Nimble
import UIKit
@testable import Parchment

class DataSource: PagingViewControllerDataSource {
  
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

class PagingViewControllerSpec: QuickSpec {
  
  override func spec() {
    
    let dataSource = DataSource()
    var viewController: PagingViewController<Item>!
    
    beforeEach {
      viewController = PagingViewController()
      viewController.menuItemSize = .fixed(width: 100, height: 50)
      viewController.dataSource = dataSource
      
      UIApplication.shared.keyWindow!.rootViewController = viewController
      let _ = viewController.view
      
      viewController.collectionView.bounds = CGRect(x: 0, y: 0, width: 1000, height: 50)
    }
    
    describe("PagingViewController") {
      
      it("reloadItems: at begining") {
        viewController.selectPagingItem(Item(index: 0))
        let items = viewController.collectionView.numberOfItems(inSection: 0)
        expect(items).to(equal(21))
      }
      
      it("reloadItems: at center") {
        viewController.selectPagingItem(Item(index: 20))
        let items = viewController.collectionView.numberOfItems(inSection: 0)
        expect(items).to(equal(21))
      }
      
      it("reloadItems: at end") {
        viewController.selectPagingItem(Item(index: 50))
        let items = viewController.collectionView.numberOfItems(inSection: 0)
        expect(items).to(equal(21))
      }
      
    }
    
  }
  
}

