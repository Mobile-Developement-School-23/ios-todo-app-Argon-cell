import UIKit

class AuthorizationViewController: UIViewController {

    let dataManager: DataManager
    
    // MARK: - Views
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = "Не корректный токен или остуствует интернет"
        label.font = .subhead
        label.isHidden = true
        return label
    }()
    
    private lazy var typeTokenLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primaryLabel
        label.text = "Введите ваш токен"
        label.font = .body
        return label
    }()
    
    private lazy var tokenTextView: TextView = {
        let textView = TextView()
        textView.isScrollEnabled = true
        textView.autocapitalizationType = .none
        textView.text = tokenLabel
        textView.font = .body
        textView.textColor = .customSecondaryLabel
        textView.backgroundColor = .secondaryBack
        return textView
    }()
    
    private lazy var authorizateButton: UIButton = {
       let button = UIButton()
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = .primaryLabel
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: edgeSize, leading: edgeSize, bottom: edgeSize, trailing: edgeSize)
        button.setAttributedTitle(NSAttributedString(string: "Авторизоваться", attributes: [NSAttributedString.Key.font: UIFont.subhead ?? .preferredFont(forTextStyle: .subheadline)]), for: .normal)
        button.addTarget(nil, action: #selector(authorizationButtonTap), for: .touchUpInside)
        
        button.backgroundColor = .secondaryBack
        button.layer.cornerRadius = cornerRadius

        return button
    }()
    
    private lazy var mainStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = edgeSize
        return stack
    }()
    
    // MARK: - Inits
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isToolbarHidden = true
        view.backgroundColor = .iosPrimaryBack
        tokenTextView.delegate = self
        
        setupViews()
    }
    
    // MARK: - Setup methods
    private func setupViews() {
        addSubviews()
        setupLayout()
    }
    
    private func addSubviews() {
        view.addSubview(mainStack)
        
        mainStack.addArrangedSubview(typeTokenLabel)
        mainStack.addArrangedSubview(errorLabel)
        mainStack.addArrangedSubview(tokenTextView)
        mainStack.addArrangedSubview(authorizateButton)
        
        hideKeyboardWhenTappedAround()
    }
    
    private func setupLayout() {
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        authorizateButton.translatesAutoresizingMaskIntoConstraints = false
        authorizateButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        typeTokenLabel.translatesAutoresizingMaskIntoConstraints = false
        typeTokenLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        tokenTextView.translatesAutoresizingMaskIntoConstraints = false
        tokenTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        tokenTextView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    // MARK: - Objc methods
    @objc func authorizationButtonTap(sender: UIButton) {
        errorLabel.isHidden = true
        dataManager.updateNetworkToken(tokenTextView.text)
        
        dataManager.checkToken { valid in
            DispatchQueue.main.async {
                if valid {
                    UserDefaults.standard.set(self.tokenTextView.text, forKey: "auth_token")
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationController?.setViewControllers([TodoListViewController(dataManagerService: self.dataManager)], animated: true)
                } else {
                    self.errorLabel.isHidden = false
                }
            }
        }
    }

}

// MARK: - Extension
extension AuthorizationViewController: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == tokenLabel {
            textView.text = ""
            textView.textColor = .primaryLabel
        }
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = tokenLabel
            textView.textColor = .customSecondaryLabel
        }
        return true
    }
}

private let tokenLabel = "Токен"
