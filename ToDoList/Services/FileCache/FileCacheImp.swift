import Foundation

final class FileCacheImp: Storable, FileCache {
    // MARK: - Properties
    var isDirty: Bool

    private let storageType: StorageType
    private(set) var todoItems: [String: TodoItem] = [:]
    var markeredToDeleteItems: [String: Int] = [:]
    var markeredToUpdateItems: [String: Int] = [:]
    
    // MARK: - Inits
    init(storageType: StorageType, todoItems: [String: TodoItem]) {
        self.storageType = storageType
        self.todoItems = todoItems
        self.isDirty = true
    }
    
    convenience init(storageType: StorageType) {
        self.init(storageType: storageType, todoItems: [:])
    }
    
    // MARK: - Methods
    
    //Get methods
    func getItem(id: String) -> TodoItem? {
        return todoItems[id]
    }
    
    func getList() -> [TodoItem] {
        return Array(todoItems.values)
    }
    
    //Set methods
    func addElement(_ item: TodoItem) {
        if let oldItem = todoItems[item.id] {
            if item != oldItem {
                if item.dateChanging >= oldItem.dateChanging {
                    todoItems[item.id] = item
                }
            }
        } else {
            todoItems[item.id] = item
        }
    }
    
    func updateElement(_ item: TodoItem) {
        if item != todoItems[item.id] {
            addElement(item)
        }
    }
    
    func setList(_ items: [TodoItem]) {
        todoItems = [:]
        for item in items {
            addElement(item)
        }
    }
    
    func mergeList(_ items: [TodoItem]) {
        for item in items {
            if markeredToDeleteItems[item.id] == nil {
                addElement(item)
            }
        }
    }
    
    func deleteElement(_ item: TodoItem) {
        todoItems[item.id] = nil

    }
    
    func save(to file: String) throws {
        switch storageType {
        case .json:
            try? saveToJSON(file: file)
        case .csv:
            try? saveToCSV(file: file)
        }
    }
    
    func load(from file: String) throws {
        switch storageType {
        case .json:
            try loadFromJSON(file: file)
        case .csv:
            try saveToCSV(file: file)
        }
    }
}

// MARK: - Extensions
extension FileCacheImp {
    func loadFromJSON(file name: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.directoryNotFound }

        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.json.rawValue)
        debugPrint("Путь файла - " + pathWithFileName.absoluteString)
        
        guard let data = try? Data(contentsOf: pathWithFileName) else { throw FileCacheErrors.pathToFileNotFound }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [Any] else { throw FileCacheErrors.jSONConvertationError }

        for jsonItem in jsonObject {
            if let parsedItem = TodoItem.parse(json: jsonItem) {
                addElement(parsedItem)
            }
        }
    }

    func saveToJSON(file name: String) throws {
        let todoJsonItems = todoItems.map { $1.json }

        guard let data = try? JSONSerialization.data(withJSONObject: todoJsonItems) else { throw FileCacheErrors.jSONConvertationError }

        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.directoryNotFound }

        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.json.rawValue)

        do {
            try data.write(to: pathWithFileName)
        } catch {
            throw FileCacheErrors.pathToFileNotFound
        }
    }
}

extension FileCacheImp {
    func loadFromCSV(file name: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.directoryNotFound }
        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.csv.rawValue)

        guard let data = try? String(contentsOf: pathWithFileName, encoding: .utf8) else { throw FileCacheErrors.pathToFileNotFound }

        var rows = data.description.components(separatedBy: Constants.csvLineSeparator)
        rows.removeFirst()

        for row in rows {
            if let item = TodoItem.parse(csv: String(row)) {
                addElement(item)
            }
        }
    }

    func saveToCSV(file name: String) throws {
        var dataToSave = [Constants.csvHeaderFormat]

        for todoCSVItem in todoItems.map({ $1.csv }) {
            dataToSave.append(todoCSVItem)
        }

        let joinedString = dataToSave.joined(separator: Constants.csvLineSeparator)

        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.directoryNotFound }
        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.csv.rawValue)

        do {
            try joinedString.write(to: pathWithFileName, atomically: true, encoding: .utf8)
        } catch {
            throw FileCacheErrors.pathToFileNotFound
        }
    }
}

// MARK: - Enums

enum FileCacheErrors: String, Error {
    case directoryNotFound = "Директория файла не найдена, попробуйте поменять в fileCache папки"
    case jSONConvertationError = "Ошибка с конвертацией JSON файла"
    case pathToFileNotFound = "Путь до файла не найден, проверьте конечный путь"
    case writeFileError = "Ошибка при записи файла"
}

extension FileCacheImp {
    private enum FileFormat: String {
        case csv = ".csv"
        case json = ".json"
    }
    
    enum Constants {
        static let csvHeaderFormat = "id;text;importance;date_deadline;is_done;date_creation;date_changing"
        static let csvLineSeparator = "/r/n"
    }
}
