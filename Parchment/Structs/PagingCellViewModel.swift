import Foundation

struct PagingTitleCellViewModel {
  let title: String?
  let font: UIFont
  let textColor: UIColor
  let selectedTextColor: UIColor
  let selected: Bool
  
  init(title: String?, selected: Bool, options: PagingOptions) {
    self.title = title
    self.font = options.font
    self.textColor = options.textColor
    self.selectedTextColor = options.selectedTextColor
    self.selected = selected
  }
  
}
