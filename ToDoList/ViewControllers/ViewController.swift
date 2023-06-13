import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileCache = FileCache()
        try? fileCache.loadFromCSV(file: "file")
        fileCache.add(TodoItem(text: "новая задача", importance: .important, deadline: nil, isDone: false, dateChanging: nil))
        fileCache.add(TodoItem(text: "новая задач32323а", importance: .important, deadline: nil, isDone: false, dateChanging: nil))
        fileCache.add(TodoItem(text: "новая 32423432", importance: .important, deadline: nil, isDone: false, dateChanging: nil))
        try? fileCache.saveToCSV(file: "file")
        
        print(fileCache.todoItems)
        
//        var todoItem1 = TodoItem.parse(json: ["id": "12",
//                                             "text": "сделать домашку по второй лекции",
//                                             "importance": "ordinary",
//                                             "deadline": nil,
//                                             "is_done": false,
//                                             "date_creation": 10000000.0,
//                                             "date_changing": nil])!
//        var todoItem2 = TodoItem.parse(json: ["id": "23",
//                                             "text": "сделать домашку по второй лекции",
//                                             "importance": "ordinary",
//                                             "deadline": nil,
//                                             "is_done": false,
//                                             "date_creation": 10000000.0,
//                                             "date_changing": nil])!
//
//        fileCache.add(todoItem1)
//        fileCache.add(todoItem2)
//        print(fileCache.todoItems)
//        
//        do {
//            try fileCache.saveToJSON(file: "file_2")
//        } catch _ as Error {
//            print("error")
//        }
//        
//        fileCache.remove(with: "1")
//        fileCache.remove(with: "2")
//        print(fileCache.todoItems)
//        
//        do {
//            try fileCache.loadFromJSON(file: "file_2")
//        } catch _ as Error {
//            print("error")
//        }
//        
//        print(fileCache.todoItems)
//        
//        print(getDocumentsDirectory())
        
        
//        var item = TodoItem.parse(csv: "1;текст;;;false;312321332.9;")!
//        print(item.csv)
//        try? TodoItem.pa(from: "file")
//        try? fileCache.loadFromCSV(file: "file")
//        print(fileCache.todoItems)
        

//        fileCache.add(todoItem1)
//        fileCache.add(todoItem2)
//        try? fileCache.saveToCSV(file: "file")
//
//        print(fileCache.todoItems)
//        var fileCache2 = FileCache()
//        try? fileCache2.loadFromCSV(file: "file")
//        print(fileCache2.todoItems)
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

