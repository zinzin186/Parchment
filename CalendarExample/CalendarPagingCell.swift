import UIKit
import Parchment

class CalendarPagingCell: PagingCell {
  
  private var theme: PagingTheme?
  
  lazy var dateLabel: UILabel = {
    let dateLabel = UILabel(frame: .zero)
    dateLabel.font = UIFont.systemFontOfSize(20)
    return dateLabel
  }()
  
  lazy var weekdayLabel: UILabel = {
    let weekdayLabel = UILabel(frame: .zero)
    weekdayLabel.font = UIFont.systemFontOfSize(12)
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
  
  override var selected: Bool {
    didSet {
      updateSelectedState()
    }
  }
  
  private func configure() {
    addSubview(dateLabel)
    addSubview(weekdayLabel)
    
    dateLabel.translatesAutoresizingMaskIntoConstraints = false
    weekdayLabel.translatesAutoresizingMaskIntoConstraints = false
    
    let verticalDateLabelContraint = NSLayoutConstraint(
      item: dateLabel,
      attribute: .CenterY,
      relatedBy: .Equal,
      toItem: self,
      attribute: .CenterY,
      multiplier: 1.0,
      constant: -9)
    
    let horizontalDateLabelContraint = NSLayoutConstraint(
      item: dateLabel,
      attribute: .CenterX,
      relatedBy: .Equal,
      toItem: self,
      attribute: .CenterX,
      multiplier: 1.0,
      constant: 0)
    
    let verticalWeekdayLabelContraint = NSLayoutConstraint(
      item: weekdayLabel,
      attribute: .CenterY,
      relatedBy: .Equal,
      toItem: self,
      attribute: .CenterY,
      multiplier: 1.0,
      constant: 12)
    
    let horizontalWeekdayLabelContraint = NSLayoutConstraint(
      item: weekdayLabel,
      attribute: .CenterX,
      relatedBy: .Equal,
      toItem: self,
      attribute: .CenterX,
      multiplier: 1.0,
      constant: 0)
    
    addConstraints([
      verticalDateLabelContraint,
      horizontalDateLabelContraint,
      verticalWeekdayLabelContraint,
      horizontalWeekdayLabelContraint
    ])
  }
  
  private func updateSelectedState() {
    guard let theme = theme else { return }
    if selected {
      dateLabel.textColor = theme.selectedTextColor
      weekdayLabel.textColor = theme.selectedTextColor
    } else {
      dateLabel.textColor = theme.textColor
      weekdayLabel.textColor = theme.textColor
    }
  }
  
  override func setPagingItem(pagingItem: PagingItem, theme: PagingTheme) {
    let calendarItem = pagingItem as! CalendarItem
    dateLabel.text = DateFormatters.dateFormatter.stringFromDate(calendarItem.date)
    weekdayLabel.text = DateFormatters.weekdayFormatter.stringFromDate(calendarItem.date)
    
    self.theme = theme
    updateSelectedState()
  }
  
}
