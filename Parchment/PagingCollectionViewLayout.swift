import UIKit

class PagingCollectionViewLayout: UICollectionViewFlowLayout {
  
  var pagingState: PagingState
  
  private let options: PagingOptions
  private let pagingIndicatorLayoutAttributes: PagingIndicatorLayoutAttributes
  
  init(pagingState: PagingState, options: PagingOptions) {
    
    self.pagingState = pagingState
    self.options = options
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
    pagingIndicatorLayoutAttributes.configure(options)
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
      
      let upcomingIndex = pagingState.upcomingIndex ?? pagingState.currentIndex
      
      let from = PagingIndicatorMetric(
        frame: indicatorFrameForIndex(pagingState.currentIndex),
        insets: indicatorInsetsForIndex(pagingState.currentIndex))
      
      let to = PagingIndicatorMetric(
        frame: indicatorFrameForIndex(upcomingIndex),
        insets: indicatorInsetsForIndex(upcomingIndex))
      
      pagingIndicatorLayoutAttributes.update(from: from, to: to, progress: pagingState.offset)
      return pagingIndicatorLayoutAttributes
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
