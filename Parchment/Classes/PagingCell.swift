import UIKit

public class PagingCell: UICollectionViewCell {
  public func setPagingItem(pagingItem: PagingItem, theme: PagingTheme) {
    fatalError("setPagingItem: not implemented")
  }
}

public class DefaultPagingCell: PagingCell {

  private var viewModel: PagingCellViewModel?
  private let titleLabel = UILabel(frame: .zero)
  
  public override var selected: Bool {
    didSet {
      configureTitleLabel()
    }
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }

  public override func setPagingItem(pagingItem: PagingItem, theme: PagingTheme) {
    if let titleItem = pagingItem as? PagingTitleItem {
      viewModel = PagingCellViewModel(title: titleItem.title, theme: theme)
    }
    configureTitleLabel()
  }
  
  private func configure() {
    contentView.addSubview(titleLabel)
    contentView.addConstraintsForFullscreenSubview(titleLabel)
  }
  
  private func configureTitleLabel() {
    guard let viewModel = viewModel else { return }
    titleLabel.text = viewModel.title
    titleLabel.font = viewModel.font
    titleLabel.textAlignment = .Center
    
    if selected {
      titleLabel.textColor = viewModel.selectedTextColor
    } else {
      titleLabel.textColor = viewModel.textColor
    }
  }
  
}
