import UIKit

extension Date {
    func toString(with format: String = "d MMMM yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    static func getNextDayDate() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
}
