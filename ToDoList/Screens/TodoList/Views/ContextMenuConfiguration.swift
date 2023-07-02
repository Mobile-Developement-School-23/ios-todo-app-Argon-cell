import Foundation
import UIKit

extension TodoListViewController {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let currentTodoItem = todoItems[indexPath.row]
        guard currentTodoItem.dateСreation != .distantPast else { return nil }
        
        let conifguration = UIContextMenuConfiguration(identifier: currentTodoItem.id as NSCopying, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            let textSaveAction = currentTodoItem.isDone ? makeUndoneActionText : makeDoneActionText
            let imageSaveAction: UIImage? = currentTodoItem.isDone ? .undoneCircleIcon : .greenCheckMarkCircleIcon
            
            let saveAction = UIAction(title: textSaveAction, image: imageSaveAction) { _ in
                self.itemDoneAction(indexPath.row)
                self.makeSave()
                tableView.reloadData()
            }
            
            let deleteAction = UIAction(title: deleteActionText, image: .redTrashIcon) { _ in
                self.todoItems.remove(at: indexPath.row)
                self.updateCount()
                self.makeSave()
                tableView.reloadData()
            }
            
            let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [saveAction, deleteAction])
            
            return menu
        }
            
        return conifguration
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        let item = todoItems.first(where: { $0.id == configuration.identifier as? String ?? "" })
        let vc = TodoItemViewController(item: item)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.setUserInteractionDisabled()
        show(vc, sender: nil)
    }
    
    func updateCount() {
        let filteredTodoItemsCount = todoItems.filter { $0.isDone }.count
        headerView.update(filteredTodoItemsCount == 0 ? doneTodoItems.count : filteredTodoItemsCount)
    }
}

private let makeDoneActionText = "Make done"
private let makeUndoneActionText = "Make undone"
private let deleteActionText = "Delete"
