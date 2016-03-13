import UIKit

class PagingCollectionViewLayout: UICollectionViewFlowLayout {
  
  var state: PagingState
  
  private let options: PagingOptions
  private let indicatorLayoutAttributes: PagingIndicatorLayoutAttributes
  private let borderLayoutAttributes: PagingBorderLayoutAttributes
  
  private var range: Range<Int> {
    return 0..<(collection.numberOfItemsInSection(0) - 1)
  }
  
  init(state: PagingState, options: PagingOptions) {
    
    self.state = state
    self.options = options
    
    self.indicatorLayoutAttributes = PagingIndicatorLayoutAttributes(
      forDecorationViewOfKind: PagingIndicatorView.defaultReuseIdentifier,
      withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    
    self.borderLayoutAttributes = PagingBorderLayoutAttributes(
      forDecorationViewOfKind: PagingBorderView.defaultReuseIdentifier,
      withIndexPath: NSIndexPath(forItem: 1, inSection: 0))
    
    super.init()
    
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError(InitCoderError)
  }
  
  private func configure() {
    minimumLineSpacing = 0
    minimumInteritemSpacing = 0
    scrollDirection = .Horizontal
    register(PagingIndicatorView.self)
    register(PagingBorderView.self)
    indicatorLayoutAttributes.configure(options)
    borderLayoutAttributes.configure(options)
  }
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var layoutAttributes = super.layoutAttributesForElementsInRect(rect)!
    
    layoutAttributes.append(layoutAttributesForDecorationViewOfKind(PagingIndicatorView.defaultReuseIdentifier,
      atIndexPath: NSIndexPath(forItem: 0, inSection: 0))!)
    
    layoutAttributes.append(layoutAttributesForDecorationViewOfKind(PagingBorderView.defaultReuseIdentifier,
      atIndexPath: NSIndexPath(forItem: 1, inSection: 0))!)
    
    return layoutAttributes
  }
  
  override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    
    if elementKind == PagingIndicatorView.defaultReuseIdentifier {
      
      let from = PagingIndicatorMetric(
        frame: indicatorFrameForIndex(state.currentIndex),
        insets: indicatorInsetsForIndex(state.currentIndex))
      
      let to = PagingIndicatorMetric(
        frame: indicatorFrameForIndex(state.targetIndex),
        insets: indicatorInsetsForIndex(state.targetIndex))
      
      indicatorLayoutAttributes.update(from: from, to: to, progress: fabs(state.offset))
      return indicatorLayoutAttributes
    }
    
    if elementKind == PagingBorderView.defaultReuseIdentifier {
      borderLayoutAttributes.update(width: collectionViewContentSize().width)
      return borderLayoutAttributes
    }
    
    return super.layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
  }
  
  // MARK: Private
  
  private func indicatorInsetsForIndex(index: Int) -> PagingIndicatorMetric.Inset {
    if case let .Visible(_, _, insets, _) = options.indicatorOptions {
      if index == range.startIndex {
        return .Left(insets.left)
      } else if index >= range.endIndex {
        return .Right(insets.right)
      }
    }
    return .None
  }
  
  private func indicatorFrameForIndex(index: Int) -> CGRect {
    if index < range.startIndex {
      let frame = frameForIndex(state.currentIndex)
      return frame.offsetBy(dx: -frame.width, dy: 0)
    } else if index > range.endIndex {
      let frame = frameForIndex(state.currentIndex)
      return frame.offsetBy(dx: frame.width, dy: 0)
    } else {
      return frameForIndex(index)
    }
  }
  
  private func frameForIndex(index: Int) -> CGRect {
    let currentIndexPath = NSIndexPath(forItem: index, inSection: 0)
    let layoutAttributes = layoutAttributesForItemAtIndexPath(currentIndexPath)!
    return layoutAttributes.frame
  }
  
}
