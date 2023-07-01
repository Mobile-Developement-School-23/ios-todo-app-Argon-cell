import UIKit
import TodoItem

class TodoListViewController: UIViewController {
    let fileCache = FileCache()
    var doneTodoItems: [TodoItem] = []
    var todoItems: [TodoItem] = []
    
    lazy var headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
    
    lazy var plusButton = UIButton()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .insetGrouped)
        tableView.register(TodoItemTableViewCell.self, forCellReuseIdentifier: TodoItemTableViewCell.identifier)
        tableView.tableHeaderView = headerView
        tableView.backgroundColor = .primaryBack
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeLoad()
        setUpView()
    }
    
    private func makeLoad() {
        do {
            try fileCache.loadFromJSON(file: mainDataBaseFileName)
        } catch {
            print("Ошибочка при загрузке данных")
        }
        
        todoItems = fileCache.toArray().sorted(by: { $0.dateСreation > $1.dateСreation })
        removeDoneTodoItems()
        todoItems.append(TodoItem(text: "", importance: .important, dateСreation: Date.distantPast))
        headerView.update(doneCount: doneTodoItems.count)
    }
    
    private func setUpView() {
        title = navigationTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .primaryBack
        
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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configurePlusButtonFrame()
    }
    
    override func viewDidLayoutSubviews() {
        view.addSubview(configureButton(button: plusButton))
    }
    
    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
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
    
    func makeSave() {
        var todoItemsToSave = todoItems + doneTodoItems
        todoItemsToSave.sort(by: { $0.dateСreation > $1.dateСreation })
        todoItemsToSave.removeLast()
        fileCache.saveArrayToJSON(todoItems: todoItemsToSave, to: mainDataBaseFileName)
    }
}

private let navigationTitle = "Мои дела"
