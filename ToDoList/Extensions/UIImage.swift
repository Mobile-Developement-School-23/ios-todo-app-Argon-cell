import Foundation
import UIKit

extension UIImage {
    static var lowImportanceIcon: UIImage? { return UIImage(systemName: "arrow.down")?.withTintColor(.customSecondaryLabel ?? .secondaryLabel, renderingMode: .alwaysOriginal) }
    static var highImportanceIcon: UIImage? { return UIImage(systemName: "exclamationmark.2")?.withTintColor(.customRed ?? .red, renderingMode: .alwaysOriginal) }
    static var redTrashIcon: UIImage? { return UIImage(systemName: "trash.fill")?.withTintColor(.customRed ?? .red, renderingMode: .alwaysOriginal) }
    static var whiteTrashIcon: UIImage? { return UIImage(systemName: "trash.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal) }
    static var greenCheckMarkCircleIcon: UIImage? { return UIImage(named: "done.green") }
    static var whiteCheckMarkCircleIcon: UIImage? { return UIImage(named: "done.white") }
    static var undoneCircleIcon: UIImage? { return UIImage(named: "prop.off")?.withTintColor(.primaryLabel!, renderingMode: .automatic) }
    static var importantCircleIcon: UIImage? { return UIImage(named: "prop.high.importance") }
    static var chevroneRightIcon: UIImage? { return UIImage(named: "chevrone.right") }
    static var calendarIcon: UIImage? { return UIImage(systemName: "calendar")?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal) }
    static var offlineIcon: UIImage? { return UIImage(systemName: "icloud.slash.fill")?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal) }
//    static var logoutIcon: UIImage? { return UIImage(systemName: "rectangle.portrait.and.arrow.right.fill")?.withTintColor(.systemBlue ?? .blue, renderingMode: .alwaysOriginal) }
    static var plusIcon: UIImage? { return UIImage(named: "plus.icon") }
}
