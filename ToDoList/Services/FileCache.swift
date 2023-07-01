import Foundation
import CocoaLumberjackSwift
import TodoItem
// MARK: - Class

final class FileCache {
    private(set) var todoItems: [String: TodoItem] = [:]

    func toArray() -> [TodoItem] {
        return Array(todoItems.values)
    }
    
    func add(_ item: TodoItem) {
        todoItems[item.id] = item
    }

    func remove(with id: String) -> TodoItem? {
        if let itemIntList = todoItems[id] {
            todoItems[id] = nil
            return itemIntList
        } else {
            return nil
        }
    }
}

// MARK: - Extensions

extension FileCache {
    func loadFromJSON(file name: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            DDLogError("[Load JSON] " + FileCacheErrors.directoryNotFound.rawValue)
            throw FileCacheErrors.directoryNotFound
        }
        
        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.json.rawValue)

        guard let data = try? Data(contentsOf: pathWithFileName) else {
            DDLogError("[Load JSON] " + FileCacheErrors.pathToFileNotFound.rawValue)
            throw FileCacheErrors.pathToFileNotFound
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [Any] else {
            DDLogError("[Load JSON] " + FileCacheErrors.jSONConvertationError.rawValue)
            throw FileCacheErrors.jSONConvertationError
        }

        for jsonItem in jsonObject {
            if let parsedItem = TodoItem.parse(json: jsonItem) {
                add(parsedItem)
            }
        }
    }

    func saveToJSON(file name: String) throws {
        let todoJsonItems = todoItems.map { $1.json }

        guard let data = try? JSONSerialization.data(withJSONObject: todoJsonItems) else {
            DDLogError("[Save JSON] " + FileCacheErrors.jSONConvertationError.rawValue)
            throw FileCacheErrors.jSONConvertationError
        }

        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            DDLogError("[Save JSON] " + FileCacheErrors.directoryNotFound.rawValue)
            throw FileCacheErrors.directoryNotFound
        }

        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.json.rawValue)

        do {
            try data.write(to: pathWithFileName)
        } catch {
            DDLogError("[Save JSON] " + FileCacheErrors.pathToFileNotFound.rawValue)
            throw FileCacheErrors.pathToFileNotFound
        }
    }
}

extension FileCache {
    func loadFromCSV(file name: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {

            throw FileCacheErrors.directoryNotFound }
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

extension FileCache {
    func saveArrayToJSON(todoItems: [TodoItem], to file: String) {
        self.todoItems = Dictionary(uniqueKeysWithValues: todoItems.map({($0.id, $0)}))
        do {
            try self.saveToJSON(file: file)
        } catch FileCacheErrors.directoryNotFound {
            print(FileCacheErrors.directoryNotFound.rawValue)
        } catch FileCacheErrors.jSONConvertationError {
            print(FileCacheErrors.jSONConvertationError.rawValue)
        } catch FileCacheErrors.pathToFileNotFound {
            print(FileCacheErrors.pathToFileNotFound.rawValue)
        } catch FileCacheErrors.writeFileError {
            print(FileCacheErrors.writeFileError.rawValue)
        } catch {
           
            print("Другая ошибка при сохранении файла")
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
