import Foundation
import UIKit

extension UIImage {
    static var lowImportanceIcon: UIImage? { return UIImage(named: "LowImportance") }
    static var highImportanceIcon: UIImage? { return UIImage(named: "HighImportance") }
    static var redTrashIcon: UIImage? { return UIImage(systemName: "trash.fill")?.withTintColor(.customRed ?? .red, renderingMode: .alwaysOriginal) }
    static var whiteTrashIcon: UIImage? { return UIImage(systemName: "trash.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal) }
    static var greenCheckMarkCircleIcon: UIImage? { return UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.customGreen ?? .green, renderingMode: .alwaysOriginal) }
    static var whiteCheckMarkCircleIcon: UIImage? { return UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal) } 
    static var undoneCircleIcon: UIImage? { return UIImage(systemName: "circle")?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal) }
    static var importantCircleIcon: UIImage? { return UIImage(systemName: "circle")?.withTintColor(.customRed ?? .red, renderingMode: .alwaysOriginal) }
    static var chevroneRightIcon: UIImage? { return UIImage(systemName: "chevron.right")?.withTintColor(.secondaryLabel ?? .gray, renderingMode: .alwaysOriginal) }
    static var calendarIcon: UIImage? { return UIImage(systemName: "calendar")?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal) }
}
