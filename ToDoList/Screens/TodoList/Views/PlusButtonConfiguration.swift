import UIKit

extension TodoListViewController {

    func configurePlusButtonFrame() {
        plusButton.frame = CGRect(x: view.bounds.midX - 25, y: view.bounds.maxY - 100, width: 40, height: 40)
   }
    
     func configureButton(button: UIButton) -> UIButton {

        let image = UIImage(systemName: "plus.circle.fill")?.withTintColor(.blue, renderingMode: .alwaysOriginal)
  
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
         
        button.setImage(image, for: .normal)
         
        button.backgroundColor = .clear
         button.layer.shadowColor = UIColor.blue.cgColor
         button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 8
        
        
        button.addTarget(self, action: #selector(tapPlusButton), for: .touchUpInside)

        return button
    }
    
    @objc func tapPlusButton() {
        
        let vc = TodoItemViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .formSheet
        
        vc.dataCompletionHandler = { [self] data in
            if let todoItem = data {
                self.todoItems.append(todoItem)
                self.todoItems.sort(by: { $0.dateСreation > $1.dateСreation })
                self.tableView.reloadData()
                
                makeSave()
            }
        }
        vc.setupNavigatorButtons()
        present(navigationController, animated: true, completion: nil)
    }
}
