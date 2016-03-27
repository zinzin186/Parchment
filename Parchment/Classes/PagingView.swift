import UIKit

class PagingView: UIView {
  
  private let pagingContentView: UIView
  private let collectionView: UICollectionView
  private let options: PagingOptions
  
  init(pagingContentView: UIView, collectionView: UICollectionView, options: PagingOptions) {
    
    self.pagingContentView = pagingContentView
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
    addSubview(pagingContentView)
    setupConstraints()
  }
  
  private func setupConstraints() {
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    pagingContentView.translatesAutoresizingMaskIntoConstraints = false
    
    let metrics = [
      "height": options.menuItemSize.height]
    
    let views = [
      "collectionView": collectionView,
      "pagingContentView": pagingContentView]
    
    let horizontalCollectionViewContraints = NSLayoutConstraint.constraintsWithVisualFormat(
      "H:|[collectionView]|",
      options: .DirectionLeadingToTrailing,
      metrics: metrics,
      views: views)
    
    let horizontalPagingContentViewContraints = NSLayoutConstraint.constraintsWithVisualFormat(
      "H:|[pagingContentView]|",
      options: .DirectionLeadingToTrailing,
      metrics: metrics,
      views: views)
    
    let verticalContraints = NSLayoutConstraint.constraintsWithVisualFormat(
      "V:|[collectionView(==height)][pagingContentView]|",
      options: .DirectionLeadingToTrailing,
      metrics: metrics,
      views: views)
    
    addConstraints(horizontalCollectionViewContraints)
    addConstraints(horizontalPagingContentViewContraints)
    addConstraints(verticalContraints)
  }
  
}
