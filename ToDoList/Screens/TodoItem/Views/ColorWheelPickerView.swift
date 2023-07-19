import UIKit

protocol ColorPickerDelegate: AnyObject {
    func colorPickerViewDidSelectColor(_ view: ColorPickerView, color: UIColor)
}

class ColorPickerView: UIView {
    var viewLayer: CAGradientLayer = .init()
    weak var delegate: ColorPickerDelegate?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupGradientLayer()
    }

    private func setupGradientLayer() {
        guard viewLayer.superlayer == nil else { return }

        viewLayer.colors = [
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        ]
        viewLayer.startPoint = CGPoint(x: 0, y: 0.5)
        viewLayer.endPoint = CGPoint(x: 1, y: 0.5)
        viewLayer.frame = bounds
        viewLayer.cornerRadius = 16

        layer.addSublayer(viewLayer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognizer))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizer))
        addGestureRecognizer(panGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        viewLayer.frame = bounds
        setupGradientLayer()
    }

    @objc func gestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)

        guard let selectedColor = viewLayer.colorOfPoint(point: location) else { return }
        if selectedColor == UIColor(red: 0, green: 0, blue: 0, alpha: 0) { return }
        DispatchQueue.main.async {
            self.delegate?.colorPickerViewDidSelectColor(self, color: selectedColor)
        }
    }
}

extension CALayer {
    func colorOfPoint(point: CGPoint) -> UIColor? {
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context = CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        context.translateBy(x: -point.x, y: -point.y)

        render(in: context)
        let red = CGFloat(pixel[0]) / 255.0
        let green = CGFloat(pixel[1]) / 255.0
        let blue = CGFloat(pixel[2]) / 255.0
        let alpha = CGFloat(pixel[3]) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
