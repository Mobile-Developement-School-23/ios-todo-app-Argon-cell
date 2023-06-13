import Foundation

//MARK: - Class

final class FileCache {
    private(set) var todoItems: [TodoItem]
    
    init(todoItems: [TodoItem]) {
        self.todoItems = todoItems
    }
    
    convenience init() {
        self.init(todoItems: [])
    }
    
    func add(_ item: TodoItem) {
        if todoItems.filter({ $0.id == item.id }).count == 0 {
            todoItems.append(item)
        }
    }
    
    func remove(with id: String) -> TodoItem? {
        for (index, todoItem) in todoItems.enumerated() {
            todoItems.remove(at: index)
            return todoItem
        }
        return nil
    }
    
    func loadFromJSON(file name: String) throws {
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.DirectoryNotFound }
        
        let pathWithFileName = documentDirectory.appendingPathComponent(name + ".json")
        guard let data = try? Data(contentsOf: pathWithFileName) else { throw FileCacheErrors.PathToFileNotFound }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [Any] else { throw FileCacheErrors.JSONConvertationError }
        
        for jsonItem in jsonObject {
            if let parsedItem = TodoItem.parse(json: jsonItem) {
                self.add(parsedItem)
            }
        }
    }
    
    func saveToJSON(file name: String) throws {
        let todoJsonItems = todoItems.map( { $0.json } )
        
        guard let data = try? JSONSerialization.data(withJSONObject: todoJsonItems) else { throw FileCacheErrors.JSONConvertationError }
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.DirectoryNotFound }
        
        let pathWithFileName = documentDirectory.appendingPathComponent(name + ".json")
        
        do {
            try data.write(to: pathWithFileName)
        } catch {
            throw FileCacheErrors.PathToFileNotFound
        }
    }
    
    
}


extension FileCache {
    func loadFromCSV(file name: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.DirectoryNotFound }
        let pathWithFileName = documentDirectory.appendingPathComponent(name + ".csv")
        
        guard let data = try? String(contentsOf: pathWithFileName, encoding: .utf8) else { throw FileCacheErrors.PathToFileNotFound }
        
        var rows = data.description.components(separatedBy: "\r\n")
        rows.removeFirst()

        for row in rows {
            if let item = TodoItem.parse(csv: String(row)) {
                self.add(item)
            }
        }
    }
    
    func saveToCSV(file name: String) throws {
        var dataToSave: Array<String> = ["id;text;importance;deadline;is_done;date_creation;date_changing"]
        
        for todoCSVItem in todoItems.map( { $0.csv } ) {
            dataToSave.append(todoCSVItem)
        }

        let joinedString = dataToSave.joined(separator: "\r\n")

        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.DirectoryNotFound }
        let pathWithFileName = documentDirectory.appendingPathComponent(name + ".csv")

        do {
            try joinedString.write(to: pathWithFileName, atomically: true, encoding: .utf8)
        } catch {
            throw FileCacheErrors.PathToFileNotFound
        }
    }
}
//MARK: - Enum errors

enum FileCacheErrors: Error {
    case DirectoryNotFound
    case JSONConvertationError
    case PathToFileNotFound
    case WriteFileError
}
