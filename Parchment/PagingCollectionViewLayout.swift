import UIKit

class PagingCollectionViewLayout: UICollectionViewFlowLayout {
  
  var pagingState: PagingState
  var pagingIndicatorLayoutAttributes: PagingIndicatorLayoutAttributes
  
  init(pagingState: PagingState) {
    self.pagingState = pagingState
    self.pagingIndicatorLayoutAttributes = PagingIndicatorLayoutAttributes(
      forDecorationViewOfKind: PagingIndicator.defaultReuseIdentifier,
      withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
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
    register(PagingIndicator.self)
  }
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var layoutAttributes = super.layoutAttributesForElementsInRect(rect)!
    layoutAttributes.append(layoutAttributesForDecorationViewOfKind(PagingIndicator.defaultReuseIdentifier, atIndexPath: NSIndexPath(forItem: 0, inSection: 0))!)
    return layoutAttributes
  }
  
  override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    if elementKind == PagingIndicator.defaultReuseIdentifier {
      
      let from = PagingIndicatorMetric(frame: indicatorFrameForIndex(pagingState.currentIndex))
      let to = PagingIndicatorMetric(frame: indicatorFrameForIndex(pagingState.upcomingIndex ?? pagingState.currentIndex))
      
      pagingIndicatorLayoutAttributes.configure(from: from, to: to, progress: pagingState.offset)
      return pagingIndicatorLayoutAttributes
    }
    return super.layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
  }
  
  // MARK: Private
  
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
