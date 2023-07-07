import Foundation

final class FileCacheImp: Storable, FileCache {
    var isDirty: Bool

    private let storageType: StorageType
    private(set) var todoItems: [String: TodoItem] = [:]
    
    func getItems() -> [TodoItem] {
        return Array(todoItems.values)
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
    
    // Overloading update methods
    func setItems(_ items: [TodoItem]) {
        todoItems = [:]
        for item in items {
            add(item)
        }
    }
    func update(_ items: [TodoItem]) {
        for item in items {
            add(item)
        }
    }

    func update(_ item: TodoItem) {
        add(item)
    }
    
    func add(_ item: TodoItem) {
        todoItems[item.id] = item
    }
    
    // Overloading remove methods
    @discardableResult
    func remove(with id: String) -> TodoItem? {
        if let itemIntList = todoItems[id] {
            todoItems[id] = nil
            return itemIntList
        } else {
            return nil
        }
    }
    
    func remove(_ item: TodoItem) {
        remove(with: item.id)
    }
    
    init(storageType: StorageType, todoItems: [String: TodoItem]) {
        self.storageType = storageType
        self.todoItems = todoItems
        self.isDirty = true
    }
    
    convenience init(storageType: StorageType) {
        self.init(storageType: storageType, todoItems: [:])
    }
}

// MARK: - Extensions
extension FileCacheImp {
    func loadFromJSON(file name: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.directoryNotFound }

        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.json.rawValue)
        debugPrint(pathWithFileName)
        
        guard let data = try? Data(contentsOf: pathWithFileName) else { throw FileCacheErrors.pathToFileNotFound }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [Any] else { throw FileCacheErrors.jSONConvertationError }

        for jsonItem in jsonObject {
            if let parsedItem = TodoItem.parse(json: jsonItem) {
                add(parsedItem)
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

        var rows = data.description.components(separatedBy: csvLineSeparator)
        rows.removeFirst()

        for row in rows {
            if let item = TodoItem.parse(csv: String(row)) {
                add(item)
            }
        }
    }

    func saveToCSV(file name: String) throws {
        var dataToSave = [csvHeaderFormat]

        for todoCSVItem in todoItems.map({ $1.csv }) {
            dataToSave.append(todoCSVItem)
        }

        let joinedString = dataToSave.joined(separator: csvLineSeparator)

        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.directoryNotFound }
        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.csv.rawValue)

        do {
            try joinedString.write(to: pathWithFileName, atomically: true, encoding: .utf8)
        } catch {
            throw FileCacheErrors.pathToFileNotFound
        }
    }
}

extension FileCacheImp {
    func saveArrayToJSON(todoItems: [TodoItem], to file: String) {
        self.todoItems = Dictionary(uniqueKeysWithValues: todoItems.map({($0.id, $0)}))
        do {
            try self.saveToJSON(file: file)
        } catch FileCacheErrors.directoryNotFound {
            debugPrint(FileCacheErrors.directoryNotFound.rawValue)
        } catch FileCacheErrors.jSONConvertationError {
            debugPrint(FileCacheErrors.jSONConvertationError.rawValue)
        } catch FileCacheErrors.pathToFileNotFound {
            debugPrint(FileCacheErrors.pathToFileNotFound.rawValue)
        } catch FileCacheErrors.writeFileError {
            debugPrint(FileCacheErrors.writeFileError.rawValue)
        } catch {
            debugPrint("Другая ошибка при сохранении файла")
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

private enum FileFormat: String {
    case csv = ".csv"
    case json = ".json"
}

private let csvHeaderFormat = "id;text;importance;date_deadline;is_done;date_creation;date_changing"
private let csvLineSeparator = "/r/n"
