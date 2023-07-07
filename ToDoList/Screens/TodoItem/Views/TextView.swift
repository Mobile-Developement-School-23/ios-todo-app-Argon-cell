import UIKit

class TextView: UITextView {

    init() {
        super.init(frame: .zero, textContainer: .none)
        setupTextView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextView() {
        self.font = UIFont.body
        self.autocorrectionType = .no
        self.layer.cornerRadius = 16
        self.layer.backgroundColor = UIColor.secondaryBack?.cgColor
        
        self.isScrollEnabled = false
        self.textContainerInset = UIEdgeInsets.init(top: 16, left: 11, bottom: 16, right: 16)

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        layer.backgroundColor = UIColor.secondaryBack?.cgColor
    }
}
