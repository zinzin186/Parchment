import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
  
  static let reuseIdentifier: String = "ImageCellIdentifier"
  
  private lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .ScaleAspectFill
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.clipsToBounds = true
    contentView.addSubview(imageView)
    contentView.constrainToEdges(imageView)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setImage(image: UIImage) {
    imageView.image = image
  }
  
}
