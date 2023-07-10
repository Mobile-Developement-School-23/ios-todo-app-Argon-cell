import UIKit

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoItemTableViewCell.identifier, for: indexPath) as? TodoItemTableViewCell else { fatalError("Ошибка в создании ячейки") }
        cell.configureCell(todoItems[indexPath.row])
        cell.checkMarkButton.addTarget(self, action: #selector(self.checkMarkTap), for: .touchUpInside)
        cell.checkMarkButton.tag = indexPath.row
        return cell
    }
        
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.todoItems[indexPath.row].dateСreation != .distantPast {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, handler in
                guard let self = self else { return }
                let item = self.todoItems[indexPath.row]
                self.dataManagerService.deleteElementLocally(item)
                self.startLoading()
                self.dataManagerService.deleteElementNetwork(item)
                handler(true)
            }
            deleteAction.image = .whiteTrashIcon
            deleteAction.backgroundColor = .customRed ?? .red
                    
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.todoItems[indexPath.row].dateСreation != .distantPast {
            let doneAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, handler in
                guard let self = self else { return }
                var item = self.todoItems[indexPath.row]
                item.isDone = !item.isDone
                item.dateChanging = Date()
                self.dataManagerService.updateElementLocally(item)
                self.startLoading()
                self.dataManagerService.updateElementNetwork(item)
                handler(true)
            }
            doneAction.image = .whiteCheckMarkCircleIcon
            doneAction.backgroundColor = .customGreen ?? .green
            
            let configuration = UISwipeActionsConfiguration(actions: [doneAction])
            return configuration
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currentTodoItem: TodoItem?
        
        if todoItems[indexPath.row].dateСreation == .distantPast {
            currentTodoItem = nil
        } else {
            currentTodoItem = todoItems[indexPath.row]
        }
        
        let vc = TodoItemViewController(item: currentTodoItem)
        vc.setupNavigatorButtons()
        
        let navigationController = UINavigationController(rootViewController: vc)

        vc.dataCompletionHandler = { [weak self] item in
            guard let self = self else { return }
               
            if currentTodoItem != nil {
                if let item = item {
                    self.dataManagerService.updateElementLocally(item)
                    self.startLoading()
                    self.dataManagerService.updateElementNetwork(item)
                } else {
                    let item = self.todoItems[indexPath.row]
                    self.dataManagerService.deleteElementLocally(item)
                    self.startLoading()
                    self.dataManagerService.deleteElementNetwork(item)
                }
            } else {
                if let item = item {
                    self.dataManagerService.addElementLocally(item)
                    self.startLoading()
                    self.dataManagerService.addElementNetwork(item)
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        present(navigationController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 50
    }
    
    @objc func checkMarkTap(sender: UIButton) {
        var item = todoItems[sender.tag]
        item.isDone = !item.isDone
        self.dataManagerService.updateElementLocally(item)
        self.startLoading()
        self.dataManagerService.updateElementNetwork(item)
    }
}
