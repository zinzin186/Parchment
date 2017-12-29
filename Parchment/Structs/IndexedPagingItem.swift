import UIKit

public struct PagingIndexItem: PagingTitleItem, Equatable, Hashable, Comparable {
  
  public let index: Int
  public let title: String
  
  public var hashValue: Int {
    return index
  }
  
  public init(index: Int, title: String) {
    self.title = title
    self.index = index
  }
  
  public static func ==(lhs: PagingIndexItem, rhs: PagingIndexItem) -> Bool {
    return lhs.index == rhs.index && lhs.title == rhs.title
  }
  
  public static func <(lhs: PagingIndexItem, rhs: PagingIndexItem) -> Bool {
    return lhs.index < rhs.index
  }
}

