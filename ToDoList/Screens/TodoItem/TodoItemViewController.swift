import UIKit

final class TodoItemViewController: UIViewController {
    // MARK: - Properties
    
    private lazy var textView = TextView()
    private lazy var scrollView = UIScrollView()

    // StackView properties
    private lazy var settingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .secondaryBack
        stackView.layer.cornerRadius = cornerRadius
        stackView.axis = .vertical
        stackView.spacing = settingsStackViewSpacing
        stackView.layoutMargins = UIEdgeInsets(top: verticalStackEdgeSize, left: edgeSize, bottom: verticalStackEdgeSize, right: edgeSize)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var deadlineVerticalSubStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var importanceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = edgeSize
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var deadlineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = edgeSize
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var colorPickerLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = edgeSize
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var colorPickerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = edgeSize
        stackView.alignment = .leading
        return stackView
    }()
    
    // Label properties
    private lazy var importanceLabel: BodyLabelView = {
        let label = BodyLabelView()
        label.text = importanceTitle
        return label
    }()
    
    private lazy var deadlineLabel: BodyLabelView = {
        let label = BodyLabelView()
        label.text = doBeforeTitle
        return label
    }()
    
    private lazy var colorPickerLabel: BodyLabelView = {
        let label = BodyLabelView()
        label.text = colorTextTitle
        return label
    }()
    
    private lazy var hexColorLabel: BodyLabelView = {
        let label = BodyLabelView()
        label.text = UIColor.primaryLabel.toHex()
        return label
    }()
    
    // SegmentControl properties
    private lazy var importanceSegmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.selectedSegmentTintColor = .elevatedBack
        segmentControl.backgroundColor = .overlaySupport
        return segmentControl
    }()

    // Switch properties
    private lazy var dateDeadLineSwtich: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = .green
        switcher.layer.cornerRadius = cornerRadius
        switcher.layer.masksToBounds = true
        switcher.backgroundColor = .overlaySupport
        switcher.addTarget(nil, action: #selector(switchChanged), for: .valueChanged)
        return switcher
    }()

    // Button properties
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(deleteTitle, for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.tertiaryLabel, for: .disabled)
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = .secondaryBack
        button.addTarget(nil, action: #selector(deleteTodoItem), for: .touchUpInside)
        return button
    }()
    
    private lazy var dateDeadlineButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.blue, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(nil, action: #selector(dateDeadlineButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Calendar properties
    private lazy var calendarView: UIDatePicker = {
        let datePicker = UIDatePicker()

        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.minimumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline

        datePicker.addTarget(nil, action: #selector(datePickerSelected), for: .valueChanged)
        datePicker.isHidden = true
        return datePicker
    }()
    
    private var textHeightConstraint: NSLayoutConstraint? = nil
    private var settingsAndDeleteConstraints: [NSLayoutConstraint] = []

    // SeparatorViews properties
    private lazy var separator = SeparatorLineView()
    private lazy var secondSeparator = SeparatorLineView()
    private lazy var thirdSeparator = SeparatorLineView()
    private lazy var fourthSeparator = SeparatorLineView()
    
    private lazy var selectedColorButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = .red
        button.addTarget(nil, action: #selector(selectColorTap), for: .touchUpInside)
        return button
    }()
    
    // ColorPickerView properties
    private lazy var colorPickerView = ColorPickerView()
    
    // UISlider properties
    private lazy var colorBrightnessSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0004
        slider.value = 0.5
        slider.maximumValue = 1.0
        slider.isContinuous = true
        slider.addTarget(nil, action: #selector(sliderChange), for: .valueChanged)
        return slider
    }()
    
//    private let fileCache = FileCache()
    private var currentTodoItem: TodoItem? = nil
    public var dataCompletionHandler: ((TodoItem?) -> Void)?
    
    // MARK: - Initializators

    init(item: TodoItem?) {
        super.init(nibName: nil, bundle: nil)
        currentTodoItem = item
    }
    
    convenience init() {
        self.init(item: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override methods

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpLandcsapeConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if textHeightConstraint == nil {
            textHeightConstraint = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: textViewHeight)
        }
        
        if UIDevice.current.orientation.isLandscape && currentTodoItem != nil {
            textHeightConstraint?.constant = UIScreen.main.bounds.height - safeAreaHeights - 2 * edgeSize - (UIApplication.shared.windows.first?.windowScene?.keyWindow?.safeAreaInsets.bottom ?? 0)
            if !settingsStackView.constraints.isEmpty && !deleteButton.constraints.isEmpty {
                settingsAndDeleteConstraints = settingsStackView.constraints + deleteButton.constraints
                settingsStackView.isHidden = true
            }
            NSLayoutConstraint.deactivate(settingsStackView.constraints + deleteButton.constraints)
            
            deleteButton.isHidden = true
        } else {
            print(settingsAndDeleteConstraints)
            NSLayoutConstraint.activate(settingsAndDeleteConstraints)
            textHeightConstraint?.constant = textViewHeight
            settingsStackView.isHidden = false
            deleteButton.isHidden = false
        }
        
        view.layoutIfNeeded()
    }
}

// MARK: - Extensions

extension TodoItemViewController {
    // MARK: - Settings views

    private func setUpView() {
        // Root view setup
        view.backgroundColor = .primaryBack
        
        // Navigation setup
        title = todoItemTitle
        
        // TextView setup
        textView.delegate = self
        
        // Separator setup
        fourthSeparator.isHidden = true
        secondSeparator.isHidden = true
        
        // ColorPickerView setup
        colorPickerView.delegate = self
        
        colorPickerStackView.isHidden = true
        calendarView.isHidden = true
        
        // TodoItem setup
        if let currentTodoItem = currentTodoItem {
            var color: UIColor? = .primaryLabel
            if let hexColor = currentTodoItem.hexColor {
                if hexColor == "#FFFFFF" || hexColor == "#000000" {
                    color = .primaryLabel
                } else {
                    color = UIColor.colorFromHex(hexColor)
                }
                hexColorLabel.text = hexColor
            } else {
                hexColorLabel.text = UIColor.primaryLabel.toHex()
            }
           
            textView.text = currentTodoItem.text
            textView.textColor = color
            selectedColorButton.backgroundColor = color
            importanceSegmentControl.selectedSegmentIndex = indexByImportance(currentTodoItem.importance)
            
            if let dateDeadline = currentTodoItem.dateDeadline {
                dateDeadlineButton.setAttributedTitle(NSAttributedString(string: dateDeadline.toString(), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]), for: .normal)
                calendarView.date = dateDeadline
                dateDeadLineSwtich.isOn = true
                dateDeadlineButton.isHidden = false
            } else {
                dateDeadlineButton.isHidden = true
            }
    
        } else {
            textView.text = placeholderTitleForTextView
            textView.textColor = .secondaryLabel
            
            selectedColorButton.backgroundColor = .primaryLabel
            importanceSegmentControl.selectedSegmentIndex = 1
        
            dateDeadlineButton.isHidden = true
            deleteButton.isEnabled = false
//            saveButton.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
                
        addSubViews()
        setupLayout()
    }
    
    // MARK: - Obj-c methods

    @objc func dismissTapped(sender: UIBarButtonItem) {
        print(1)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sliderChange(sender: UISlider) {
        selectedColorButton.backgroundColor = selectedColorButton.backgroundColor?.adjust(brightnessBy: CGFloat(sender.value))
        hexColorLabel.text = selectedColorButton.backgroundColor?.toHex()
        if textView.text != placeholderTitleForTextView {
            textView.textColor = selectedColorButton.backgroundColor
        }
    }
    
    @objc func selectColorTap(sender: UIButton) {
        if colorPickerStackView.isHidden {
            colorPickerStackView.isHidden = false
            secondSeparator.isHidden = false
        } else {
            colorPickerStackView.isHidden = true
            secondSeparator.isHidden = true
        }
    }
    
    @objc func saveTodoItem(sender: UIBarButtonItem) {
        var dateDeadline: Date?
        let importance = importanceByIndex(importanceSegmentControl.selectedSegmentIndex)
        let textColor = selectedColorButton.backgroundColor?.toHex()
        if dateDeadLineSwtich.isOn == true {
            dateDeadline = calendarView.date
        }
        
        if currentTodoItem != nil {
            currentTodoItem = TodoItem(id: currentTodoItem!.id, text: textView.text, importance: importance, dateDeadline: dateDeadline, isDone: currentTodoItem!.isDone, dateСreation: currentTodoItem!.dateСreation, dateChanging: Date(), hexColor: textColor)
        } else {
            currentTodoItem = TodoItem(text: textView.text, importance: importance, dateDeadline: dateDeadline, hexColor: textColor)
        }
        
        if let completion = dataCompletionHandler {
            completion(currentTodoItem!)
        }
        dismiss(animated: true, completion: nil)
        dismissKeyboard()
    }
    
    @objc func deleteTodoItem(sender: UIButton) {
        if let completion = dataCompletionHandler {
            completion(nil)
        }
        
        dismiss(animated: true, completion: nil)
    }
        
    @objc func switchChanged(sender: UISwitch) {
        if sender.isOn {
            let nextDayDate = Date.getNextDayDate()
            calendarView.date = nextDayDate
            dateDeadlineButton.setAttributedTitle(NSAttributedString(string: nextDayDate.toString(), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]), for: .normal)

            calendarViewAppereanceAnimation(dateSelected: false)
        } else {
            calendarViewDisappereanceAnimation(dateSelected: false)
        }
    }
    
    @objc func datePickerSelected(sender: UIDatePicker) {
        dateDeadlineButton.setAttributedTitle(NSAttributedString(string: sender.date.toString(), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]), for: .normal)
    }
    
    @objc func dateDeadlineButtonTapped(sender: UIButton) {
        if !calendarView.isHidden {
            calendarViewDisappereanceAnimation(dateSelected: true)
        } else {
            calendarViewAppereanceAnimation(dateSelected: false)
        }
    }

    // MARK: - Add subviews

    private func addSubViews() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(textView)
        scrollView.addSubview(settingsStackView)
        scrollView.addSubview(deleteButton)
        
        settingsStackView.addArrangedSubview(importanceStackView)
        settingsStackView.addArrangedSubview(separator)
        settingsStackView.addArrangedSubview(colorPickerLabelsStackView)
        settingsStackView.addArrangedSubview(secondSeparator)
        settingsStackView.addArrangedSubview(colorPickerStackView)
        settingsStackView.addArrangedSubview(thirdSeparator)
        settingsStackView.addArrangedSubview(deadlineStackView)
        settingsStackView.addArrangedSubview(fourthSeparator)
        settingsStackView.addArrangedSubview(calendarView)
        
        importanceStackView.addArrangedSubview(importanceLabel)
        importanceStackView.addArrangedSubview(importanceSegmentControl)
        
        deadlineStackView.addArrangedSubview(deadlineVerticalSubStack)
        deadlineStackView.addArrangedSubview(dateDeadLineSwtich)
        
        deadlineVerticalSubStack.addArrangedSubview(deadlineLabel)
        deadlineVerticalSubStack.addArrangedSubview(dateDeadlineButton)
        
        colorPickerLabelsStackView.addArrangedSubview(colorPickerLabel)
        colorPickerLabelsStackView.addArrangedSubview(hexColorLabel)
        colorPickerLabelsStackView.addArrangedSubview(selectedColorButton)
        
        colorPickerStackView.addArrangedSubview(colorPickerView)
        colorPickerStackView.addArrangedSubview(colorBrightnessSlider)

        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Setup layout

    private func setupLayout() {
        // ScrollView anchors
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        scrollView.contentSize = view.bounds.size
        
        // TextViewAnchors
        textView.translatesAutoresizingMaskIntoConstraints = false

        textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: edgeSize).isActive = true
        textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -edgeSize).isActive = true
        textView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: edgeSize).isActive = true
        textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * edgeSize).isActive = true
        textHeightConstraint = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: textViewHeight)
        textHeightConstraint?.isActive = true
        
        // SettingsStack anchors
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        settingsStackView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: edgeSize).isActive = true
        settingsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: edgeSize).isActive = true
        settingsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -edgeSize).isActive = true
        
        // Separators anchors
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true

        secondSeparator.translatesAutoresizingMaskIntoConstraints = false
        secondSeparator.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true

        thirdSeparator.translatesAutoresizingMaskIntoConstraints = false
        thirdSeparator.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true

        fourthSeparator.translatesAutoresizingMaskIntoConstraints = false
        fourthSeparator.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
        
        // SegmentControl anchors
        importanceSegmentControl.translatesAutoresizingMaskIntoConstraints = false

        importanceSegmentControl.widthAnchor.constraint(equalToConstant: importanceSegmentControlWidth).isActive = true
        importanceSegmentControl.heightAnchor.constraint(equalToConstant: importanceSegmentControlHeight).isActive = true

        // Deletebutton anchors
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        deleteButton.heightAnchor.constraint(equalToConstant: deleteButtonHeight).isActive = true
        deleteButton.topAnchor.constraint(equalTo: settingsStackView.bottomAnchor, constant: edgeSize).isActive = true
        deleteButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: edgeSize).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -edgeSize).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        colorPickerView.leadingAnchor.constraint(equalTo: settingsStackView.leadingAnchor, constant: edgeSize).isActive = true
        colorPickerView.trailingAnchor.constraint(equalTo: settingsStackView.trailingAnchor, constant: -edgeSize).isActive = true

        selectedColorButton.translatesAutoresizingMaskIntoConstraints = false
        selectedColorButton.heightAnchor.constraint(equalToConstant: selectedColorButtonSizes).isActive = true
        selectedColorButton.widthAnchor.constraint(equalToConstant: selectedColorButtonSizes).isActive = true

        colorBrightnessSlider.translatesAutoresizingMaskIntoConstraints = false
        colorBrightnessSlider.leadingAnchor.constraint(equalTo: settingsStackView.leadingAnchor, constant: edgeSize).isActive = true
        colorBrightnessSlider.trailingAnchor.constraint(equalTo: settingsStackView.trailingAnchor, constant: -edgeSize).isActive = true
    }
    
    private func setUpLandcsapeConstraints() {
        // Landscape constraints setup
        if UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape == true, currentTodoItem != nil {
            textHeightConstraint?.constant = UIScreen.main.bounds.height - safeAreaHeights - 2 * edgeSize - (UIApplication.shared.windows.first?.windowScene?.keyWindow?.safeAreaInsets.bottom ?? 0)
            if !settingsStackView.constraints.isEmpty {
                settingsAndDeleteConstraints = settingsStackView.constraints + deleteButton.constraints
            }
            print(settingsStackView.constraints + deleteButton.constraints)
            NSLayoutConstraint.deactivate(settingsStackView.constraints + deleteButton.constraints)
            settingsStackView.isHidden = true
            deleteButton.isHidden = true
        }
    }
    
    // MARK: - Helper functions

    func setupNavigatorButtons() {
        setupLeftNavigatorButton()
        setupRightNavigatorButton()
    }
    
    func setUserInteractionDisabled() {
        deleteButton.isHidden = true
        textView.isUserInteractionEnabled = false
        importanceSegmentControl.isUserInteractionEnabled = false
        selectedColorButton.isUserInteractionEnabled = false
        dateDeadLineSwtich.isUserInteractionEnabled = false
    }
    
    func setupLeftNavigatorButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: cancelTitle, style: .plain, target: self, action: #selector(dismissTapped(sender:)))
    }
    
    func setupRightNavigatorButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: saveTitle, style: .plain, target: self, action: #selector(saveTodoItem))
    }
    
    private func indexByImportance(_ importance: Importance) -> Int {
        switch importance {
            case .unimportant:
                return 0
            case .ordinary:
                return 1
            case .important:
                return 2
        }
    }
    
    private func importanceByIndex(_ index: Int) -> Importance {
        switch index {
            case 0:
                return .unimportant
            case 1:
                return .ordinary
            case 2:
                return .important
            default:
                return .ordinary
        }
    }
    
    // MARK: - Animations

    private func calendarViewAppereanceAnimation(dateSelected: Bool) {
        dateDeadlineButton.transform = .identity
        
        UIView.animate(withDuration: 0.3) {
            self.calendarView.isHidden = false
            self.fourthSeparator.isHidden = false
            self.dateDeadlineButton.isHidden = dateSelected ? true : false
                    
            self.calendarView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.calendarView.alpha = 0.0
            self.dateDeadlineButton.alpha = dateSelected ? 0 : 1.0
            
            self.calendarView.transform = .identity
            self.calendarView.alpha = 1.0
            self.dateDeadlineButton.alpha = 1.0
        }
    }
        
    private func calendarViewDisappereanceAnimation(dateSelected: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.calendarView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.calendarView.alpha = 1.0
            
            self.dateDeadlineButton.alpha = 1.0
            self.dateDeadlineButton.transform = .identity
                
            self.calendarView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.calendarView.alpha = 0.0
            
            self.dateDeadlineButton.transform = dateSelected ? .identity : self.dateDeadlineButton.transform.translatedBy(x: 0, y: -10)
            self.dateDeadlineButton.alpha = dateSelected ? 1.0 : 0.0
            
            self.calendarView.isHidden = true
            self.fourthSeparator.isHidden = true
            self.dateDeadlineButton.isHidden = dateSelected ? false : true
        }
    }
}

extension TodoItemViewController: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == placeholderTitleForTextView {
            textView.text = ""
            textView.textColor = selectedColorButton.backgroundColor
        }
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = placeholderTitleForTextView
            textView.textColor = .secondaryLabel
        }
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" && textView.text != placeholderTitleForTextView {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

extension TodoItemViewController: ColorPickerDelegate {
    func colorPickerViewDidSelectColor(_ view: ColorPickerView, color: UIColor) {
        selectedColorButton.backgroundColor = color
        hexColorLabel.text = color.toHex()
        colorBrightnessSlider.value = 0.5
        if textView.text != placeholderTitleForTextView && textView.text != "" {
            textView.textColor = color
        } else {
            textView.textColor = .secondaryLabel
        }
    }
}

private let selectedColorButtonSizes: CGFloat = 36
private let importanceSegmentControlHeight: CGFloat = 36
private let separatorHeight: CGFloat = 1
private let textViewHeight: CGFloat = 120
private let dateDeadlineButtonHeight: CGFloat = 18
private let deleteButtonHeight: CGFloat = 56

private let importanceSegmentControlWidth: CGFloat = 156

let cornerRadius: CGFloat = 16
let edgeSize: CGFloat = 16
private let verticalStackEdgeSize: CGFloat = 12.5
private let settingsStackViewSpacing: CGFloat = 11

private var placeholderTitleForTextView = "Что надо сделать?"

private let todoItemTitle = "Дело"

private let deleteTitle = "Удалить"
private let cancelTitle = "Отменить"
private let saveTitle = "Сохранить"

private let doBeforeTitle = "Cделать до"
private let importanceTitle = "Важность"
private let colorTextTitle = "Цвет текста"

let mainDataBaseFileName = "2"

private var items: [Any] = [UIImage.lowImportanceIcon, NSAttributedString(string: "нет", attributes: [NSAttributedString.Key.font: UIFont.subhead!]), UIImage.highImportanceIcon]
