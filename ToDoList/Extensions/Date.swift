import UIKit

extension Date {
    func toString(with format: String = "MMMMdYYYY") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    static func getNextDayDate() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
}
