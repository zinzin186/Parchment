import UIKit

class PagingView: UIView {
  
  private let pageView: UIView
  private let collectionView: UICollectionView
  private let options: PagingOptions
  
  init(pageView: UIView, collectionView: UICollectionView, options: PagingOptions) {
    
    self.pageView = pageView
    self.collectionView = collectionView
    self.options = options
    
    super.init(frame: .zero)
    
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError(InitCoderError)
  }
  
  private func configure() {
    addSubview(collectionView)
    addSubview(pageView)
    setupConstraints()
  }
  
  private func setupConstraints() {
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    pageView.translatesAutoresizingMaskIntoConstraints = false
    
    let metrics = [
      "height": options.menuItemSize.height]
    
    let views = [
      "collectionView": collectionView,
      "pageView": pageView]
    
    let horizontalCollectionViewContraints = NSLayoutConstraint.constraintsWithVisualFormat(
      "H:|[collectionView]|",
      options: .DirectionLeadingToTrailing,
      metrics: metrics,
      views: views)
    
    let horizontalPagingContentViewContraints = NSLayoutConstraint.constraintsWithVisualFormat(
      "H:|[pageView]|",
      options: .DirectionLeadingToTrailing,
      metrics: metrics,
      views: views)
    
    let verticalContraints = NSLayoutConstraint.constraintsWithVisualFormat(
      "V:|[collectionView(==height)][pageView]|",
      options: .DirectionLeadingToTrailing,
      metrics: metrics,
      views: views)
    
    addConstraints(horizontalCollectionViewContraints)
    addConstraints(horizontalPagingContentViewContraints)
    addConstraints(verticalContraints)
  }
  
}
