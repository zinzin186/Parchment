import UIKit
import Parchment

class CalendarPagingCell: PagingCell {
  
  fileprivate var theme: PagingTheme?
  
  lazy var dateLabel: UILabel = {
    let dateLabel = UILabel(frame: .zero)
    dateLabel.font = UIFont.systemFont(ofSize: 20)
    return dateLabel
  }()
  
  lazy var weekdayLabel: UILabel = {
    let weekdayLabel = UILabel(frame: .zero)
    weekdayLabel.font = UIFont.systemFont(ofSize: 12)
    return weekdayLabel
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let insets = UIEdgeInsets(top: 10, left: 0, bottom: 5, right: 0)
    
    dateLabel.frame = CGRect(
      x: 0,
      y: insets.top,
      width: contentView.bounds.width,
      height: contentView.bounds.midY - insets.top)
    
    weekdayLabel.frame = CGRect(
      x: 0,
      y: contentView.bounds.midY,
      width: contentView.bounds.width,
      height: contentView.bounds.midY - insets.bottom)
  }
  
  fileprivate func configure() {
    weekdayLabel.backgroundColor = .white
    weekdayLabel.textAlignment = .center
    dateLabel.backgroundColor = .white
    dateLabel.textAlignment = .center
    
    addSubview(weekdayLabel)
    addSubview(dateLabel)
  }
  
  fileprivate func updateSelectedState(selected: Bool) {
    guard let theme = theme else { return }
    if selected {
      dateLabel.textColor = theme.selectedTextColor
      weekdayLabel.textColor = theme.selectedTextColor
    } else {
      dateLabel.textColor = theme.textColor
      weekdayLabel.textColor = theme.textColor
    }
  }
  
  override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, theme: PagingTheme) {
    let calendarItem = pagingItem as! CalendarItem
    dateLabel.text = calendarItem.dateText
    weekdayLabel.text = calendarItem.weekdayText
    
    self.theme = theme
    updateSelectedState(selected: selected)
  }
  
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    guard let theme = theme else { return }

    if let attributes = layoutAttributes as? PagingCellLayoutAttributes {
      dateLabel.textColor = UIColor.interpolate(
        from: theme.textColor,
        to: theme.selectedTextColor,
        with: attributes.progress)
      
      weekdayLabel.textColor = UIColor.interpolate(
        from: theme.textColor,
        to: theme.selectedTextColor,
        with: attributes.progress)
    }
  }
  
}
