import UIKit

/// An implementation of the `PagingItem` protocol that stores the
/// index and title of a given item. The index property is needed to
/// make the `PagingItem` comparable.
public struct PagingTitleItem: PagingItem, Equatable, Comparable {
  
  /// The index of the `PagingItem` instance
  public let index: Int
  
  /// The title used in the menu cells.
  public let title: String
  
  public var identifier: Int {
    return index
  }
  
  /// Creates an instance of `PagingTitleItem`
  ///
  /// Parameter index: The index of the `PagingItem`.
  /// Parameter title: The title used in the menu cells.
  public init(title: String, index: Int) {
    self.title = title
    self.index = index
  }
  
  public static func ==(lhs: PagingTitleItem, rhs: PagingTitleItem) -> Bool {
    return lhs.index == rhs.index && lhs.title == rhs.title
  }
  
  public static func <(lhs: PagingTitleItem, rhs: PagingTitleItem) -> Bool {
    return lhs.index < rhs.index
  }
}
