import UIKit

final class HeaderView: UIView {
    private lazy var doneCountLabel = UILabel()
    private lazy var showButton = UIButton()
    private lazy var appStatusLabel: UILabel = {
        let label = UILabel()

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = .offlineIcon
        let imageOffsetY: CGFloat = -5.0
        imageAttachment.bounds = CGRect(x: -5.0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
    
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.subhead ?? .preferredFont(forTextStyle: .subheadline)])
        completeText.append(attachmentString)
        label.textAlignment = .center
        label.attributedText = completeText
        
        return label
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    var doneCount = 0
    var areDoneCellsHiden = true
    public var change: ((Bool) -> Void)?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ count: Int = 0) {
        self.doneCount = count
        self.doneCountLabel.text = doneText + String(count)
    }
    
    private func setupViews() {
        doneCountLabel.text = doneText + String(doneCount)
        doneCountLabel.textColor = .customSecondaryLabel
        
        showButton.setAttributedTitle(NSAttributedString(string: showText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.customBlue ?? .blue, NSAttributedString.Key.font: UIFont.subhead ?? UIFont.preferredFont(forTextStyle: .subheadline)]), for: .normal)
        showButton.setAttributedTitle(NSAttributedString(string: hideText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.customBlue ?? .blue, NSAttributedString.Key.font: UIFont.subhead ?? UIFont.preferredFont(forTextStyle: .subheadline)]), for: .selected)

        showButton.addTarget(self, action: #selector(showButtonTap), for: .touchUpInside)
    
        showButton.setTitleColor(.customBlue, for: .normal)
        showButton.contentHorizontalAlignment = .trailing
        
        addSubview(mainStack)
        
        mainStack.addArrangedSubview(appStatusLabel)
        mainStack.addArrangedSubview(doneCountLabel)
        mainStack.addArrangedSubview(showButton)

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.leftAnchor.constraint(equalTo: self.leftAnchor, constant: edgeSize).isActive = true
        mainStack.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -edgeSize).isActive = true
        mainStack.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
         
        appStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        appStatusLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        showButton.translatesAutoresizingMaskIntoConstraints = false
        
        showButton.rightAnchor.constraint(equalTo: self.mainStack.rightAnchor).isActive = true
        showButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    @objc func showButtonTap() {
        showButton.isSelected = areDoneCellsHiden
        
        areDoneCellsHiden = !areDoneCellsHiden
        
        if let completion = change {
            if areDoneCellsHiden {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func showNetworkSyncErrorLabel() {
        self.appStatusLabel.isHidden = false
    }
    func hideNetworkSyncErrorLabel() {
        self.appStatusLabel.isHidden = true
    }
}

private let showText = "Показать"
private let hideText = "Скрыть"
private let doneText = "Выполнено — "
