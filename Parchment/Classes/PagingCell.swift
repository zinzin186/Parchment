import UIKit
import Cartography

class PagingCell: UICollectionViewCell {
  
  private let titleLabel = UILabel(frame: .zero)
  
  var viewModel: PagingCellViewModel? {
    didSet {
      configureTitleLabel()
    }
  }
  
  override var selected: Bool {
    didSet {
      configureTitleLabel()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError(InitCoderError)
  }
  
  private func configure() {
    contentView.addSubview(titleLabel)
    constrain(contentView, titleLabel) { contentView, titleLabel in
      titleLabel.centerX == contentView.centerX
      titleLabel.centerY == contentView.centerY
    }
  }
  
  private func configureTitleLabel() {
    guard let viewModel = viewModel else { return }
    titleLabel.text = viewModel.title
    titleLabel.font = viewModel.font
    
    if selected {
      titleLabel.textColor = viewModel.selectedTextColor
    } else {
      titleLabel.textColor = viewModel.textColor
    }
  }
  
}
