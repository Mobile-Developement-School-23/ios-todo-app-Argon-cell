import Foundation
import UIKit

extension TodoListViewController {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        var currentTodoItem = todoItems[indexPath.row]
        guard currentTodoItem.dateСreation != .distantPast else { return nil }
        
        let conifguration = UIContextMenuConfiguration(identifier: currentTodoItem.id as NSCopying, previewProvider: nil) { _ in
            let textSaveAction = currentTodoItem.isDone ? makeUndoneActionText : makeDoneActionText
            let imageSaveAction: UIImage? = currentTodoItem.isDone ? .undoneCircleIcon : .greenCheckMarkCircleIcon
            
            let doneAction = UIAction(title: textSaveAction, image: imageSaveAction) { _ in
                currentTodoItem.isDone = !currentTodoItem.isDone
                currentTodoItem.dateChanging = Date()
                self.dataManagerService.updateElementLocally(currentTodoItem)
                self.tableView.reloadData()
                self.startLoading()
                self.dataManagerService.updateElementNetwork(currentTodoItem)
            }
            
            let deleteAction = UIAction(title: deleteActionText, image: .redTrashIcon) { _ in
                self.dataManagerService.deleteElementLocally(currentTodoItem)
                self.tableView.reloadData()
                self.startLoading()
                self.dataManagerService.deleteElementNetwork(currentTodoItem)
            }
            
            let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [doneAction, deleteAction])
            
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
}

private let makeDoneActionText = "Make done"
private let makeUndoneActionText = "Make undone"
private let deleteActionText = "Delete"
