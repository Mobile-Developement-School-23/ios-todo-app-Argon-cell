import UIKit

class TodoListViewController: UIViewController {
    // MARK: - Properties
    var dataManagerService: DataManager
    
    var doneTodoItems: [TodoItem] = []
    var todoItems: [TodoItem] = []
    
    lazy var headerView = HeaderView(frame: CGRect(x: edgeSize, y: -edgeSize, width: view.bounds.width - edgeSize * 5, height: 50))
    
    lazy var plusButton: UIButton = {
        let image = UIImage.plusIcon
        let button = UIButton()
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
         
        button.setImage(image, for: .normal)
         
        button.backgroundColor = .clear
        button.layer.shadowColor = UIColor.customBlue?.cgColor ?? UIColor.blue.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 8
        
        button.addTarget(self, action: #selector(tapPlusButton), for: .touchUpInside)

        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .insetGrouped)
        tableView.register(TodoItemTableViewCell.self, forCellReuseIdentifier: TodoItemTableViewCell.identifier)
//        tableView.tableHeaderView = headerView
        tableView.backgroundColor = .iosPrimaryBack
                
        return tableView
    }()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.backgroundColor = .clear
        return activityIndicatorView
    }()
    
    // MARK: - Inits
    init(dataManagerService: DataManager) {
        self.dataManagerService = dataManagerService
        super.init(nibName: nil, bundle: nil)
    }
        
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    // MARK: - Methods
    
    private func setupNavigationBarAppearance() {
        let paragraphStyle: NSMutableParagraphStyle = .init()
        paragraphStyle.firstLineHeadIndent = edgeSize
        let largeTitleTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle]

        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.largeTitleTextAttributes = largeTitleTextAttributes
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setUpView() {
        title = navigationTitle
        setupNavigationBarAppearance()

        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        menuBtn.setAttributedTitle(NSAttributedString(string: "Выйти", attributes: [NSAttributedString.Key.font: UIFont.subhead ?? UIFont.preferredFont(forTextStyle: .subheadline)]), for: .normal)
        menuBtn.setTitleColor(.customBlue ?? .blue, for: .normal)
        menuBtn.addTarget(self, action: #selector(logoutPressed), for: .touchUpInside)

        navigationItem.rightBarButtonItem =  UIBarButtonItem(customView: menuBtn)
        view.backgroundColor = .iosPrimaryBack
        
        dataManagerService.loadListLocally()
        configureDataTable(dataManagerService.getListLocally())
        
        startLoading()
        dataManagerService.makeSynchronization()
        
        dataManagerService.dataDelegate = { preparedItems in
            DispatchQueue.main.async {
                self.configureDataTable(preparedItems)
            }
        }
        
        headerView.change = { areDoneCellsHiden in
            if areDoneCellsHiden {
                self.removeDoneTodoItems()
                self.tableView.reloadData()
            } else {
                self.addDoneItems()
                self.tableView.reloadData()
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addSubViews()
        setupLayout()
        
    }
    
    private func addSubViews() {
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(plusButton)
    }
    
    func configureDataTable(_ items: [TodoItem]) {
        if dataManagerService.storageIsDirty() {
            self.headerView.showNetworkSyncErrorLabel()
        } else {
            self.headerView.hideNetworkSyncErrorLabel()
        }
        self.todoItems = items.sorted(by: { $0.dateСreation > $1.dateСreation })
        if self.headerView.areDoneCellsHiden {
            self.removeDoneTodoItems()
            self.headerView.update(self.doneTodoItems.count)
        } else {
            headerView.update(todoItems.filter { $0.isDone }.count)
        }
        self.todoItems.append(TodoItem(text: "", importance: .important, dateСreation: Date.distantPast))

        self.tableView.reloadData()
        self.stopLoading()
    }
    
    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -edgeSize).isActive = true
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        plusButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        plusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -edgeSize).isActive = true
    
    }
    
    func startLoading() {
        plusButton.isHidden = true
        loadingView.startAnimating()
    }
    
    func stopLoading() {
        plusButton.isHidden = false
        loadingView.stopAnimating()
    }
    
    // MARK: - Objc methods
    @objc func logoutPressed(sender: UIBarButtonItem) {
         DispatchQueue.main.async {
             self.dataManagerService.updateNetworkToken(nil)
             UserDefaults.standard.set(nil, forKey: "auth_token")
             self.navigationController?.setViewControllers([AuthorizationViewController(dataManager: self.dataManagerService)], animated: true)
             self.navigationController?.isNavigationBarHidden = true
         }
     }
    
    @objc func tapPlusButton() {
        let vc = TodoItemViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .formSheet
        
        vc.dataCompletionHandler = { [self] data in
            if let todoItem = data {
                self.dataManagerService.addElementLocally(todoItem)
                self.startLoading()
                self.dataManagerService.addElementNetwork(todoItem)
            }
        }
        vc.setupNavigatorButtons()
        present(navigationController, animated: true, completion: nil)
    }
}

extension TodoListViewController {
    func removeDoneTodoItems() {
        var doneTodoItems: [TodoItem] = []
        var todoItems: [TodoItem] = []
        if self.todoItems.count > 0 {
            for i in 0..<self.todoItems.count {
                if self.todoItems[i].isDone {
                    doneTodoItems.append(self.todoItems[i])
                } else {
                    todoItems.append(self.todoItems[i])
                }
            }
        }
        
        self.doneTodoItems = doneTodoItems.sorted(by: { $0.dateСreation > $1.dateСreation })
        self.todoItems = todoItems.sorted(by: { $0.dateСreation > $1.dateСreation })
    }
    
    func addDoneItems() {
        var todoItems = self.todoItems
        
        if doneTodoItems.count > 0 {
            for i in 0...doneTodoItems.count - 1 {
                todoItems.append(doneTodoItems[i])
            }
        }
        self.todoItems = todoItems.sorted(by: { $0.dateСreation > $1.dateСreation })
        doneTodoItems = []
    }
}

private let navigationTitle = "Мои дела"
