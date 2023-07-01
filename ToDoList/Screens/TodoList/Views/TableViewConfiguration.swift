import UIKit
import TodoItem

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoItemTableViewCell.identifier, for: indexPath) as? TodoItemTableViewCell else { fatalError("Ошибка в создании ячейки") }
        cell.configureCell(todoItems[indexPath.row])
        cell.checkMarkButton.addTarget(self, action: #selector(checkMarkTap), for: .touchUpInside)
        cell.checkMarkButton.tag = indexPath.row
        return cell
    }
        
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.todoItems[indexPath.row].dateСreation != .distantPast {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, handler in
                self.todoItems.remove(at: indexPath.row)
                self.headerView.update(doneCount: self.todoItems.filter { $0.isDone }.count)
                self.makeSave()
                tableView.reloadData()
                handler(true)
            }
            deleteAction.image = UIImage(systemName: "trash.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            deleteAction.backgroundColor = .red
                    
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.todoItems[indexPath.row].dateСreation != .distantPast {
            let doneAction = UIContextualAction(style: .normal, title: nil) { _, _, handler in
                self.itemDoneAction(indexPath.row)
                self.makeSave()
                tableView.reloadData()
                handler(true)
            }
            doneAction.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            doneAction.backgroundColor = .green
            
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
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = self

        present(navigationController, animated: true, completion: nil)
        
        vc.dataCompletionHandler = { [self] item in
            if currentTodoItem != nil {
                if let item = item {
                    self.todoItems[indexPath.row] = item
                } else {
                    self.todoItems.remove(at: indexPath.row)
                }
            } else {
                if let item = item {
                    self.todoItems.append(item)
                }
            }
            headerView.update(doneCount: todoItems.filter { $0.isDone }.count)
            todoItems.sort(by: { $0.dateСreation > $1.dateСreation })
            makeSave()
            tableView.reloadData()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func itemDoneAction(_ index: Int) {
        todoItems[index].isDone = !todoItems[index].isDone
    
        if headerView.areDoneCellsHiden {
            if todoItems[index].isDone {
                doneTodoItems.append(todoItems[index])
                todoItems.remove(at: index)
                headerView.update(doneCount: doneTodoItems.count)
            }
        } else {
            headerView.update(doneCount: todoItems.filter { $0.isDone }.count)
        }
    }
    
    @objc func checkMarkTap(sender: UIButton) {
        
        self.itemDoneAction(sender.tag)
            self.makeSave()
            tableView.reloadData()
        
    }
}
