import Foundation

struct DateFormatters {
  
  static var shortDateFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeStyle = .NoStyle
    dateFormatter.dateStyle = .ShortStyle
    return dateFormatter
  }()
  
  static var dateFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "d"
    return dateFormatter
  }()
  
  static var weekdayFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "EEE"
    return dateFormatter
  }()
  
}
