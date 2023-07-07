import UIKit

class TodoItemTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "todoItemCell"
    
    private let itemTextLabel = UILabel()
    private let dateDeadlineLabel = UILabel()
    
    private let importanceImageView = UIImageView()
    private let calendarImageView = UIImageView()
    
    private let titleAndDateDeadlineStack = UIStackView()
    private let mainStack = UIStackView()
    private let dateDeadlineStack = UIStackView()
    
    let checkMarkButton = UIButton()
    private let chevroneButton = UIButton()
    
    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Methods
extension TodoItemTableViewCell {
    private func setupView() {
        titleAndDateDeadlineStack.axis = .vertical
        titleAndDateDeadlineStack.spacing = 2
        dateDeadlineStack.axis = .horizontal
        dateDeadlineStack.alignment = .center
        
        contentView.backgroundColor = .secondaryBack
        separatorInset = UIEdgeInsets(top: 0, left: checkMarkButton.bounds.width + 54, bottom: 0, right: 0)
    
        itemTextLabel.font = .body
        itemTextLabel.textColor = .primaryLabel
        itemTextLabel.numberOfLines = 3
        itemTextLabel.sizeToFit()
        
        checkMarkButton.contentVerticalAlignment = .fill
        checkMarkButton.contentHorizontalAlignment = .fill
        
        dateDeadlineLabel.font = .subhead
        dateDeadlineLabel.textColor = .customSecondaryLabel
        
        mainStack.axis = .horizontal
        mainStack.spacing = 5
        mainStack.alignment = .center
        
        dateDeadlineStack.spacing = 2
            
        chevroneButton.setImage(.chevroneRightIcon, for: .normal)
        
        addSubviews()
        setupLayout()
    }
    
    func addSubviews() {
        contentView.addSubview(checkMarkButton)
        contentView.addSubview(mainStack)
        contentView.addSubview(chevroneButton)
        
        mainStack.addArrangedSubview(importanceImageView)
        mainStack.addArrangedSubview(titleAndDateDeadlineStack)
        
        titleAndDateDeadlineStack.addArrangedSubview(itemTextLabel)
        titleAndDateDeadlineStack.addArrangedSubview(dateDeadlineStack)
        
        dateDeadlineStack.addArrangedSubview(calendarImageView)
        dateDeadlineStack.addArrangedSubview(dateDeadlineLabel)
    }
    
    func setupLayout() {
        checkMarkButton.translatesAutoresizingMaskIntoConstraints = false
        checkMarkButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        checkMarkButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        checkMarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: edgeSize).isActive = true
        checkMarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: edgeSize).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: checkMarkButton.trailingAnchor, constant: 12).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: chevroneButton.leadingAnchor, constant: -edgeSize).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -edgeSize).isActive = true
        
        chevroneButton.translatesAutoresizingMaskIntoConstraints = false
        chevroneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -edgeSize).isActive = true
        chevroneButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        chevroneButton.widthAnchor.constraint(equalToConstant: 10).isActive = true
        chevroneButton.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        importanceImageView.translatesAutoresizingMaskIntoConstraints = false
        importanceImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        importanceImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        calendarImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        calendarImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func configureCell(_ item: TodoItem) {
        if item.dateСreation == .distantPast {
            itemTextLabel.attributedText = NSAttributedString(string: "Новое", attributes: [NSAttributedString.Key.strikethroughStyle: 0])
            itemTextLabel.textColor = .tertiaryLabel
            dateDeadlineStack.isHidden = true
            chevroneButton.isHidden = true
            checkMarkButton.isHidden = true
            importanceImageView.isHidden = true
        } else {
            itemTextLabel.attributedText = NSAttributedString(string: item.text)
            if let stringColor = item.hexColor {
                if stringColor == "#FFFFFF" || stringColor == "#000000" {
                    itemTextLabel.textColor = .primaryLabel
                } else {
                    itemTextLabel.textColor = UIColor.colorFromHex(stringColor)
                }
            } else {
                itemTextLabel.textColor = .primaryLabel
            }
            
            if let dateDeadline = item.dateDeadline {
                dateDeadlineLabel.text = dateDeadline.toString(with: "d MMMM")
                calendarImageView.image = .calendarIcon
                dateDeadlineStack.isHidden = false
            } else {
                dateDeadlineStack.isHidden = true
            }
            
            chevroneButton.isHidden = false
            checkMarkButton.isHidden = false
            importanceImageView.isHidden = false
        
            switch item.importance {
            case .important:
                importanceImageView.image = .highImportanceIcon
                checkMarkButton.setImage(.importantCircleIcon, for: .normal)
            case .unimportant:
                importanceImageView.image = .lowImportanceIcon
                checkMarkButton.setImage(.undoneCircleIcon, for: .normal)
            case .ordinary:
                importanceImageView.isHidden = true
                checkMarkButton.setImage(.undoneCircleIcon, for: .normal)
            }
            
            if item.isDone {
                checkMarkButton.setImage(.greenCheckMarkCircleIcon, for: .normal)
                itemTextLabel.attributedText = NSAttributedString(string: item.text, attributes: [NSAttributedString.Key.strikethroughStyle: 1])
                itemTextLabel.textColor = .tertiaryLabel
            } else {
                itemTextLabel.attributedText = NSAttributedString(string: item.text, attributes: [NSAttributedString.Key.strikethroughStyle: 0])
            }
        }
    }
}
