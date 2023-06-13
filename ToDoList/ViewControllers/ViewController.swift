import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Проверка FileCache, для себя
        
//        let fileCache = FileCache()
//        try? fileCache.loadFromCSV(file: "file")
//        try? fileCache.loadFromJSON(file: "file_2")
//        fileCache.add(TodoItem(text: "новая задача №1", importance: .important, deadline: nil, isDone: false, dateChanging: nil))
//        fileCache.add(TodoItem(text: "новая задача №2", importance: .important, deadline: nil, isDone: false, dateChanging: nil))
//        fileCache.add(TodoItem(text: "новая задача №3", importance: .important, deadline: nil, isDone: false, dateChanging: nil))
//        try? fileCache.saveToCSV(file: "file")
//
//        print(fileCache.todoItems)
//        print(getDocumentsDirectory())
//        try? fileCache.saveToJSON(file: "file_2")
        
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

