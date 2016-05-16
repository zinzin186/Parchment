import UIKit
import Parchment

class ImagePagingCell: PagingCell {
  
  private lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .ScaleAspectFill
    return imageView
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFontOfSize(13, weight: UIFontWeightSemibold)
    label.textColor = UIColor.whiteColor()
    label.backgroundColor = UIColor(white: 0, alpha: 0.6)
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var paragraphStyle: NSParagraphStyle = {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.hyphenationFactor = 1
    paragraphStyle.alignment = .Center
    return paragraphStyle
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.layer.cornerRadius = 6
    contentView.clipsToBounds = true
    contentView.addSubview(imageView)
    contentView.addSubview(titleLabel)
    contentView.constrainToEdges(imageView)
    contentView.constrainToEdges(titleLabel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setPagingItem(pagingItem: PagingItem, theme: PagingTheme) {
    let item = pagingItem as! ImageItem
    imageView.image = item.headerImage
    titleLabel.attributedText = NSAttributedString(
      string: item.title,
      attributes: [NSParagraphStyleAttributeName: paragraphStyle])
  }
  
}
