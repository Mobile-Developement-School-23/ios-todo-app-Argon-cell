import Foundation
import UIKit

extension TodoListViewController {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if todoItems[indexPath.row].dateСreation != .distantPast {
            let conifguration = UIContextMenuConfiguration(identifier: todoItems[indexPath.row].id as NSCopying, previewProvider: nil) { _ in
                var textSaveAction = "Make done"
                var imageSaveAction = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.green, renderingMode: .alwaysOriginal)
                if self.todoItems[indexPath.row].isDone {
                    textSaveAction = "Make undone"
                    imageSaveAction = UIImage(systemName: "circle")?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
                }
                
                let saveAction = UIAction(title: textSaveAction, image: imageSaveAction) { _ in
                    self.itemDoneAction(indexPath.row)
                    self.makeSave()
                    tableView.reloadData()
                }
                
                let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)) { _ in
                    self.todoItems.remove(at: indexPath.row)
                    self.headerView.update(doneCount: self.todoItems.filter { $0.isDone }.count)
                    self.makeSave()
                    tableView.reloadData()
                }
                
                let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [saveAction, deleteAction])
                
                return menu
            }
            
            return conifguration
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        let item = todoItems.first(where: { $0.id == configuration.identifier as! String })
        let vc = TodoItemViewController(item: item)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.setUserInteractionDisabled()

        show(vc, sender: nil)
    }
}
