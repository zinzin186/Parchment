import UIKit

class PagingView: UIView {
  
  fileprivate let pageView: UIView
  fileprivate let collectionView: UICollectionView
  fileprivate let options: PagingOptions
  
  init(pageView: UIView, collectionView: UICollectionView, options: PagingOptions) {
    
    self.pageView = pageView
    self.collectionView = collectionView
    self.options = options
    
    super.init(frame: .zero)
    
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  fileprivate func configure() {
    addSubview(collectionView)
    addSubview(pageView)
    setupConstraints()
  }
  
  fileprivate func setupConstraints() {
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    pageView.translatesAutoresizingMaskIntoConstraints = false
    
    let metrics = [
      "height": options.menuHeight]
    
    let views = [
      "collectionView": collectionView,
      "pageView": pageView]
    
    let horizontalCollectionViewContraints = NSLayoutConstraint.constraints(
      withVisualFormat: "H:|[collectionView]|",
      options: NSLayoutFormatOptions(),
      metrics: metrics,
      views: views)
    
    let horizontalPagingContentViewContraints = NSLayoutConstraint.constraints(
      withVisualFormat: "H:|[pageView]|",
      options: NSLayoutFormatOptions(),
      metrics: metrics,
      views: views)
    
    let verticalContraints = NSLayoutConstraint.constraints(
      withVisualFormat: "V:|[collectionView(==height)][pageView]|",
      options: NSLayoutFormatOptions(),
      metrics: metrics,
      views: views)
    
    addConstraints(horizontalCollectionViewContraints)
    addConstraints(horizontalPagingContentViewContraints)
    addConstraints(verticalContraints)
  }
  
}
