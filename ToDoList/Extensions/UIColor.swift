import UIKit

extension UIColor {
    static var primaryBack: UIColor? { return UIColor(named: "PrimaryBack") }
    static var secondaryBack: UIColor? { return UIColor(named: "SecondaryBack") }
    static var iosPrimaryBack: UIColor? { return UIColor(named: "iOSPrimaryBack") }
    static var elevatedBack: UIColor? { return UIColor(named: "ElevatedBack") }
    
    static var separatorSupport: UIColor? { return UIColor(named: "SeparatorSupport") }
    static var overlaySupport: UIColor? { return UIColor(named: "OverlaySupport") }
    
    static var tertiaryLabel: UIColor? { return UIColor(named: "TertiaryLabel") }
    static var primaryLabel: UIColor? { return UIColor(named: "PrimaryLabel") }
    
    static var green: UIColor? { return UIColor(named: "Green") }
    static var red: UIColor? { return UIColor(named: "Red") }
    static var blue: UIColor? { return UIColor(named: "Blue") }
    
    func toHex() -> String? {
        guard let components = cgColor.components else {
            return nil
        }
           
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
           
        let hexString = String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        return hexString
    }

    static func colorFromHex(_ hex: String) -> UIColor? {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        guard hexString.count == 6 else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func adjust(hueBy hue: CGFloat = 0, saturationBy saturation: CGFloat = 0, brightnessBy brightness: CGFloat = 0) -> UIColor {
        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0

        if getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentAlpha) {
            return UIColor(hue: currentHue,
                           saturation: currentSaturation,
                           brightness: brightness,
                           alpha: currentAlpha)
        } else {
            return self
        }
    }
}
