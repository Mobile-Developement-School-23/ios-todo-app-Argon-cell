import UIKit
import TodoItem

class TodoItemTableViewCell: UITableViewCell {
    
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
    
    private let checkMarkImage = UIImage(systemName: "circle")?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
    private let checkHighImportanceMarkImage = UIImage(systemName: "circle")?.withTintColor(.red, renderingMode: .alwaysOriginal)
    private let checkDoneMarkImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.green, renderingMode: .alwaysOriginal)
    private let calendarImage = UIImage(systemName: "calendar")?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupView() {
        titleAndDateDeadlineStack.axis = .vertical
        dateDeadlineStack.axis = .horizontal
        
        contentView.backgroundColor = .secondaryBack
        
        itemTextLabel.font = .body
        itemTextLabel.textColor = .primaryLabel
        itemTextLabel.numberOfLines = 3
        itemTextLabel.sizeToFit()
        
        checkMarkButton.contentVerticalAlignment = .fill
        checkMarkButton.contentHorizontalAlignment = .fill
        
        dateDeadlineLabel.font = .subhead
        dateDeadlineLabel.textColor = .secondaryLabel
        
        mainStack.axis = .horizontal
        mainStack.spacing = 2
        mainStack.alignment = .top
        
        dateDeadlineStack.spacing = 2
            
        chevroneButton.imageView?.image = UIImage(named: "ChevronRight")
         
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
        chevroneButton.widthAnchor.constraint(equalToConstant: 7).isActive = true
        chevroneButton.heightAnchor.constraint(equalToConstant: 11).isActive = true
        
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
            itemTextLabel.textColor = .secondaryLabel
            dateDeadlineStack.isHidden = true
            chevroneButton.isHidden = true
            checkMarkButton.isHidden = true
            importanceImageView.isHidden = true
        } else {
            itemTextLabel.attributedText = NSAttributedString(string: item.text)
            itemTextLabel.textColor = UIColor.colorFromHex(item.hexColor ?? "")
            
            if let dateDeadline = item.dateDeadline {
                dateDeadlineLabel.text = dateDeadline.toString()
                calendarImageView.image = calendarImage
                dateDeadlineStack.isHidden = false
            } else {
                dateDeadlineStack.isHidden = true
            }
        
            chevroneButton.isHidden = false
            chevroneButton.setImage(UIImage(named: "ChevronRight"), for: .normal)
            
            checkMarkButton.isHidden = false
            importanceImageView.isHidden = false
            switch item.importance {
            case .important:
                importanceImageView.image = UIImage(named: "HighImportance")
                checkMarkButton.setImage(checkHighImportanceMarkImage, for: .normal)
            case .unimportant:
                importanceImageView.image = UIImage(named: "LowImportance")
                checkMarkButton.setImage(checkMarkImage, for: .normal)
            case .ordinary:
                importanceImageView.isHidden = true
                checkMarkButton.setImage(checkMarkImage, for: .normal)
            }
            
            if item.isDone {
                checkMarkButton.setImage(checkDoneMarkImage, for: .normal)
                itemTextLabel.attributedText = NSAttributedString(string: item.text, attributes: [NSAttributedString.Key.strikethroughStyle: 1])
            } else {
                itemTextLabel.attributedText = NSAttributedString(string: item.text, attributes: [NSAttributedString.Key.strikethroughStyle: 0])
            }
        }
    }
    
}
