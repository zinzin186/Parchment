import UIKit
import Parchment

struct IconPagingCellViewModel {
  
  let title: String
  let selected: Bool
  let tintColor: UIColor
  let selectedTintColor: UIColor
  
  init(title: String, selected: Bool, theme: PagingTheme) {
    self.title = title
    self.selected = selected
    self.tintColor = theme.textColor
    self.selectedTintColor = theme.selectedTextColor
  }
}

class IconPagingCell: PagingCell {
  
  fileprivate var viewModel: IconPagingCellViewModel?
  
  fileprivate lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, theme: PagingTheme) {
    if let item = pagingItem as? PagingTitleItem {
      updateViewModel(viewModel: IconPagingCellViewModel(
        title: item.title,
        selected: selected,
        theme: theme))
    }
  }
  
  open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    guard let viewModel = viewModel else { return }
    if let attributes = layoutAttributes as? PagingCellLayoutAttributes {
      let scale = (0.4 * attributes.progress) + 0.6
      imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
      imageView.tintColor = UIColor.interpolate(
        from: viewModel.tintColor,
        to: viewModel.selectedTintColor,
        with: attributes.progress)
    }
  }
  
  fileprivate func updateViewModel(viewModel: IconPagingCellViewModel) {
    self.viewModel = viewModel
    imageView.image = UIImage(named: viewModel.title)
    
    if viewModel.selected {
      imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
      imageView.tintColor = viewModel.selectedTintColor
    } else {
      imageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
      imageView.tintColor = viewModel.tintColor
    }
  }
  
  private func setupConstraints() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    let topContraint = NSLayoutConstraint(
      item: imageView,
      attribute: .top,
      relatedBy: .equal,
      toItem: contentView,
      attribute: .top,
      multiplier: 1.0,
      constant: 15)
    
    let bottomConstraint = NSLayoutConstraint(
      item: imageView,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: contentView,
      attribute: .bottom,
      multiplier: 1.0,
      constant: -15)
    
    let leadingContraint = NSLayoutConstraint(
      item: imageView,
      attribute: .leading,
      relatedBy: .equal,
      toItem: contentView,
      attribute: .leading,
      multiplier: 1.0,
      constant: 0)
    
    let trailingContraint = NSLayoutConstraint(
      item: imageView,
      attribute: .trailing,
      relatedBy: .equal,
      toItem: contentView,
      attribute: .trailing,
      multiplier: 1.0,
      constant: 0)
    
    contentView.addConstraints([
      topContraint,
      bottomConstraint,
      leadingContraint,
      trailingContraint])
  }
  
}
