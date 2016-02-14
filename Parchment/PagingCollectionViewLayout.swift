import UIKit

class PagingCollectionViewLayout: UICollectionViewFlowLayout {
  
  var pagingState: PagingState
  
  private let options: PagingOptions
  private let indicatorLayoutAttributes: PagingIndicatorLayoutAttributes
  private let borderLayoutAttributes: PagingBorderLayoutAttributes
  
  init(pagingState: PagingState, options: PagingOptions) {
    
    self.pagingState = pagingState
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
    fatalError(Error.InitCoder.rawValue)
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
      let upcomingIndex = pagingState.upcomingIndex ?? pagingState.currentIndex
      
      let from = PagingIndicatorMetric(
        frame: indicatorFrameForIndex(pagingState.currentIndex),
        insets: indicatorInsetsForIndex(pagingState.currentIndex))
      
      let to = PagingIndicatorMetric(
        frame: indicatorFrameForIndex(upcomingIndex),
        insets: indicatorInsetsForIndex(upcomingIndex))
      
      indicatorLayoutAttributes.update(from: from, to: to, progress: fabs(pagingState.offset))
      return indicatorLayoutAttributes
    }
    
    if elementKind == PagingBorderView.defaultReuseIdentifier {
      borderLayoutAttributes.update(width: collectionViewContentSize().width)
      return borderLayoutAttributes
    }
    
    return super.layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
  }
  
  // MARK: Private
  
  private func indicatorInsetsForIndex(index: Int) -> UIEdgeInsets {
    switch options.indicatorOptions {
    case let .Visible(_, insets):
      if index == 0 {
        return UIEdgeInsets(top: 0, left: insets.left, bottom: 0, right: 0)
      } else if index + 1 >= collection.numberOfItemsInSection(0) {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: insets.right)
      } else {
        return UIEdgeInsets()
      }
    case .Hidden:
      return UIEdgeInsets()
    }
  }
  
  private func indicatorFrameForIndex(index: Int) -> CGRect {
    
    if index < 0 {
      let currentIndexPath = NSIndexPath(forItem: pagingState.currentIndex, inSection: 0)
      let layoutAttributes = layoutAttributesForItemAtIndexPath(currentIndexPath)!
      var frame = layoutAttributes.frame
      frame.origin.x -= frame.size.width
      return frame
    }
    
    // When the selected item is the last item in the collection
    // view, there is no upcoming layout attribute. Instead, we
    // copy the selected item's layout attributes and update its
    // frame to match where the indicator should go next
    if index >= collection.numberOfItemsInSection(0) {
      let currentIndexPath = NSIndexPath(forItem: pagingState.currentIndex, inSection: 0)
      let layoutAttributes = layoutAttributesForItemAtIndexPath(currentIndexPath)!
      var frame = layoutAttributes.frame
      frame.origin.x += frame.size.width
      return frame
    }
    
    let indexPath = NSIndexPath(forItem: index, inSection: 0)
    return layoutAttributesForItemAtIndexPath(indexPath)!.frame
    
  }
  
}
