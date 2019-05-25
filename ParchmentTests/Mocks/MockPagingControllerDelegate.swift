import Foundation
@testable import Parchment

final class MockPagingControllerDelegate: PagingControllerDelegate, Mock {
  
  enum Action: Equatable {
    case selectContent(pagingItem: Item, direction: PagingDirection, animated: Bool)
    case selectContentPrevious(animated: Bool)
    case selectContentNext(animated: Bool)
    case removeContent
  }
  
  var calls: [MockCall] = []
  
  func selectContent(pagingItem: PagingItem, direction: PagingDirection, animated: Bool) {
    calls.append(MockCall(
      datetime: Date(),
      action: .delegate(.selectContent(
        pagingItem: pagingItem as! Item,
        direction: direction,
        animated: animated
      ))
    ))
  }
  
  func selectContentPrevious(animated: Bool) {
    calls.append(MockCall(
      datetime: Date(),
      action: .delegate(.selectContentPrevious(animated: animated))
    ))
  }
  
  func selectContentNext(animated: Bool) {
    calls.append(MockCall(
      datetime: Date(),
      action: .delegate(.selectContentNext(animated: animated))
    ))
  }
  
  func removeContent() {
    calls.append(MockCall(
      datetime: Date(),
      action: .delegate(.removeContent)
    ))
  }
  
}
