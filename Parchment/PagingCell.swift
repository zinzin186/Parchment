import UIKit
import Cartography

class PagingCell: UICollectionViewCell {
  
  var title: String? {
    didSet {
      self.titleLabel.text = self.title
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  private func configure() {
    contentView.backgroundColor = UIColor.redColor()
    contentView.addSubview(titleLabel)
    constrain(contentView, titleLabel) { contentView, titleLabel in
      titleLabel.centerX == contentView.centerX
      titleLabel.centerY == contentView.centerY
    }
  }
  
  override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    guard let attributes = layoutAttributes.copy() as? UICollectionViewLayoutAttributes else { return layoutAttributes }
    
    frame = attributes.frame
    setNeedsLayout()
    layoutIfNeeded()
    
    let size = contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    attributes.frame.size.width = size.width
    attributes.frame.size.height = 50
    
    return attributes
  }
  
  // MARK: Lazy Getters
  
  private lazy var titleLabel: UILabel = {
    let titleLabel = UILabel(frame: .zero)
    titleLabel.font = UIFont.systemFontOfSize(17)
    titleLabel.textColor = UIColor.blackColor()
    return titleLabel
  }()
  
}
