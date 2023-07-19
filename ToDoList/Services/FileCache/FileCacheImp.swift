import Foundation
import SQLite
import CoreData

final class FileCacheImp: Storable, FileCache {
    // MARK: - Properties
    var isDirty: Bool

    private let storageName: String
    private let storageType: StorageType
    
    private(set) var todoItems: [String: TodoItem] = [:]
    var markeredToDeleteItems: [String: Int] = [:]
    var markeredToUpdateItems: [String: Int] = [:]
    
    var sqliteConnection: Connection?
    var coreDataContainer: NSPersistentContainer?

    // MARK: - Inits
    init(storageType: StorageType, storageName: String, todoItems: [String: TodoItem]) {
        self.storageType = storageType
        self.todoItems = todoItems
        self.storageName = storageName
        self.isDirty = true
        
        if storageType == .sqlite {
            do {
                self.sqliteConnection = try createSqliteReference()
            } catch {
                Log.error(error.localizedDescription)
            }
        } else if storageType == .coredata {
            do {
                self.coreDataContainer = try createCoreDataReference()
            } catch {
                Log.error(error.localizedDescription)
            }
        }
    }
    
    convenience init(storageType: StorageType, name: String = "default") {
        self.init(storageType: storageType, storageName: name, todoItems: [:])
    }
    
    // MARK: - Methods
    
    // Get methods
    func getItem(id: String) -> TodoItem? {
        return todoItems[id]
    }
    
    func getList() -> [TodoItem] {
        return Array(todoItems.values)
    }
    
    // Set methods
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
        for item in items where markeredToDeleteItems[item.id] == nil {
            addElement(item)
        }
    }
    
    func deleteElement(_ item: TodoItem) {
        todoItems[item.id] = nil
        
        switch storageType {
            case .sqlite:
                deleteItemSqlite(item)
            case .coredata:
                deleteItemCoreData(item)
            default:
                break
        }
    }
    
    func save() throws {
        switch storageType {
            case .json:
                try saveToJSON()
            case .csv:
                try saveToCSV()
            case .sqlite:
                try saveToSqlite()
            case .coredata:
                try saveToCoreData()
        }
    }
    
    func load() throws {
        switch storageType {
            case .json:
                try loadFromJSON()
            case .csv:
                try loadFromCSV()
            case .sqlite:
                try loadFromSqlite()
            case .coredata:
                try loadFromCoreData()
        }
    }
    
    func getStorageType() -> StorageType {
        return storageType
    }
}

// MARK: - JSON extension
extension FileCacheImp {
    func loadFromJSON() throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.directoryNotFound }

        let pathWithFileName = documentDirectory.appendingPathComponent(storageName + FileFormat.json.rawValue)
        Log.info("Путь файла - " + pathWithFileName.absoluteString)
        
        guard let data = try? Data(contentsOf: pathWithFileName) else { throw FileCacheErrors.pathToFileNotFound }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [Any] else { throw FileCacheErrors.jSONConvertationError }

        for jsonItem in jsonObject {
            if let parsedItem = TodoItem.parse(json: jsonItem) {
                addElement(parsedItem)
            }
        }
    }

    func saveToJSON() throws {
        let todoJsonItems = todoItems.map { $1.json }

        guard let data = try? JSONSerialization.data(withJSONObject: todoJsonItems) else { throw FileCacheErrors.jSONConvertationError }

        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.directoryNotFound }

        let pathWithFileName = documentDirectory.appendingPathComponent(storageName + FileFormat.json.rawValue)

        do {
            try data.write(to: pathWithFileName)
        } catch {
            throw FileCacheErrors.pathToFileNotFound
        }
    }
}

// MARK: - CSV extension

extension FileCacheImp {
    func loadFromCSV() throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.directoryNotFound }
        let pathWithFileName = documentDirectory.appendingPathComponent(storageName + FileFormat.csv.rawValue)

        guard let data = try? String(contentsOf: pathWithFileName, encoding: .utf8) else { throw FileCacheErrors.pathToFileNotFound }

        var rows = data.description.components(separatedBy: Constants.csvLineSeparator)
        rows.removeFirst()

        for row in rows {
            if let item = TodoItem.parse(csv: String(row)) {
                addElement(item)
            }
        }
    }

    func saveToCSV() throws {
        var dataToSave = [Constants.csvHeaderFormat]

        for todoCSVItem in todoItems.map({ $1.csv }) {
            dataToSave.append(todoCSVItem)
        }

        let joinedString = dataToSave.joined(separator: Constants.csvLineSeparator)

        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.directoryNotFound }
        let pathWithFileName = documentDirectory.appendingPathComponent(storageName + FileFormat.csv.rawValue)

        do {
            try joinedString.write(to: pathWithFileName, atomically: true, encoding: .utf8)
        } catch {
            throw FileCacheErrors.pathToFileNotFound
        }
    }
}

// MARK: - SQLite extension

extension FileCacheImp {
    func createSqliteReference() throws -> Connection {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.directoryNotFound }
        let pathWithFileName = documentDirectory.appendingPathComponent(storageName + FileFormat.db.rawValue)
        guard let connection = try? Connection(pathWithFileName.absoluteString) else { throw FileCacheErrors.sqliteConnectionCreateError }
        
        try connection.run(SqliteDataModel.list.create(ifNotExists: true) { table in
            table.column(SqliteDataModel.id, primaryKey: true)
            table.column(SqliteDataModel.text)
            table.column(SqliteDataModel.importance)
            table.column(SqliteDataModel.dateDeadline, defaultValue: nil)
            table.column(SqliteDataModel.isDone)
            table.column(SqliteDataModel.hexColor, defaultValue: nil)
            table.column(SqliteDataModel.dateСreation)
            table.column(SqliteDataModel.dateChanging)
            table.column(SqliteDataModel.lastUpdatedBy)
        })
        
        Log.info("Путь файла SQLite: " + pathWithFileName.absoluteString)

        return connection
    }
    
    func saveToSqlite() throws {
        guard let sqliteDbConnection = sqliteConnection else { return }
        
        for item in todoItems.values {
            do {
                try sqliteDbConnection.execute(item.sqlReplaceStatement)
            } catch {
                throw FileCacheErrors.sqliteSaveError
            }
        }
    }

    func loadFromSqlite() throws {
        guard let sqliteDbConnection = sqliteConnection else { return }
        
        for row in try sqliteDbConnection.prepare("SELECT * FROM list") {
            if let item = TodoItem.parse(table: row as [Any]) {
                addElement(item)
            }
        }
    }
    
    func updateItemSqlite(_ item: TodoItem) {
        guard let sqliteDbConnection = sqliteConnection else { return }
        do {
            try sqliteDbConnection.execute(item.sqlReplaceStatement)
        } catch {
            Log.error(FileCacheErrors.sqliteReplaceError.localizedDescription)
        }
    }
    
    func deleteItemSqlite(_ item: TodoItem) {
        guard let sqliteDbConnection = sqliteConnection else { return }
        do {
            try sqliteDbConnection.execute(item.sqlDeleteStatement)
        } catch {
            Log.error(FileCacheErrors.sqliteDeleteError.localizedDescription)
        }
    }
    
    func insertItemSqlite(_ item: TodoItem) {
        guard let sqliteDbConnection = sqliteConnection else { return }
        do {
            try sqliteDbConnection.execute(item.sqlReplaceStatement)
        } catch {
            Log.error(FileCacheErrors.sqliteInsertError.localizedDescription)
        }
    }
    
    private enum SqliteDataModel {
        static let list = Table("list")
        static let id = Expression<String>(CodingKeys.id.rawValue)
        static let text = Expression<String>(CodingKeys.text.rawValue)
        static let importance = Expression<String>(CodingKeys.importance.rawValue)
        static let dateDeadline = Expression<Int?>(CodingKeys.dateDeadline.rawValue)
        static let isDone = Expression<Bool>(CodingKeys.isDone.rawValue)
        static let hexColor = Expression<String?>(CodingKeys.hexColor.rawValue)
        static let dateСreation = Expression<Int>(CodingKeys.dateСreation.rawValue)
        static let dateChanging = Expression<Int>(CodingKeys.dateChanging.rawValue)
        static let lastUpdatedBy = Expression<String>(CodingKeys.lastUpdatedBy.rawValue)
    }
}

// MARK: - CoreData extension

extension FileCacheImp {
    func createCoreDataReference() throws -> NSPersistentContainer {
        coreDataContainer = NSPersistentContainer(name: Constants.coreDataModelName)
        if let coreDataContainer = coreDataContainer {
            coreDataContainer.loadPersistentStores { description, _ in
                Log.info("Путь файла CoreData: " + description.url!.absoluteString)
            }
            return coreDataContainer
        } else {
            throw FileCacheErrors.coredataContainerCreateError
        }
    }
    
    func saveToCoreData() throws {
        guard let context = coreDataContainer?.viewContext else { throw FileCacheErrors.coreDataContainerNotFound }
        
        let clearRequest = NSBatchDeleteRequest(fetchRequest: TodoItemEntity.fetchRequest())
        try context.execute(clearRequest)
        
        for item in todoItems.values {
//            let fetchRequest = TodoItemEntity.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id = %@", item.id as NSString)
//
//            let fetchResults = try context.fetch(fetchRequest)
//            if fetchResults.count != 0 {
//                var loadedItem = fetchResults[0]
//                loadedItem.id = item.id
//                loadedItem.text = item.text
//                loadedItem.importanceValue = item.importance
//                loadedItem.done = item.isDone
//                loadedItem.deadline = item.dateDeadline
//                loadedItem.color = item.hexColor
//                loadedItem.createdAt = item.dateСreation
//                loadedItem.changingAt = item.dateChanging
//            } else {
                guard let todoItemEntityDescription = NSEntityDescription.entity(forEntityName: Constants.coreDataModelName, in: context) else { throw FileCacheErrors.coreDataModelDescriptionFailed }
                
                createEntity(with: item, description: todoItemEntityDescription, context: context)
//            }
        }
        
        do {
            try context.save()
        } catch {
            throw FileCacheErrors.coreDataSaveContextError
        }
    }
    
    func loadFromCoreData() throws {
        guard let context = coreDataContainer?.viewContext else { throw FileCacheErrors.coreDataContainerNotFound }
        
        do {
            let coreDataEntities = try context.fetch(TodoItemEntity.fetchRequest())
            for coreDataEntity in coreDataEntities {
                if let parsedItem = TodoItem.parse(entity: coreDataEntity) {
                    addElement(parsedItem)
                }
            }
        } catch {
            throw FileCacheErrors.coreDataLoadFromContextError
        }
    }
    
    func insertItemCoreData(_ item: TodoItem) {
        guard let context = coreDataContainer?.viewContext else {
            Log.error(FileCacheErrors.coreDataContainerNotFound.localizedDescription)
            return
        }

        guard let todoItemEntityDescription = NSEntityDescription.entity(forEntityName: Constants.coreDataModelName, in: context) else {
            Log.error(FileCacheErrors.coreDataModelDescriptionFailed.localizedDescription)
            return
        }

        createEntity(with: item, description: todoItemEntityDescription, context: context)
        
        do {
            try context.save()
        } catch {
            Log.error(FileCacheErrors.coreDataSaveContextError.localizedDescription)
        }
    }
    
    func deleteItemCoreData(_ item: TodoItem) {
        guard let context = coreDataContainer?.viewContext else {
            Log.error(FileCacheErrors.coreDataContainerNotFound.localizedDescription)
            return
        }

        let fetchRequest = TodoItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", item.id as NSString)

        do {
            let fetchResults = try context.fetch(fetchRequest)
            if fetchResults.count != 0 {
                let fetchedItemEntity = fetchResults[0]
                context.delete(fetchedItemEntity)
            }
        } catch {
            Log.error(FileCacheErrors.coreDataDeleteError.localizedDescription)
        }
        
        do {
            try context.save()
        } catch {
            Log.error(FileCacheErrors.coreDataSaveContextError.localizedDescription)
        }
    }
    
    func updateItemCoreData(_ item: TodoItem) {
        guard let context = coreDataContainer?.viewContext else {
            Log.error(FileCacheErrors.coreDataContainerNotFound.localizedDescription)
            return
        }

        guard let todoItemEntityDescription = NSEntityDescription.entity(forEntityName: Constants.coreDataModelName, in: context) else {
            Log.error(FileCacheErrors.coreDataModelDescriptionFailed.localizedDescription)
            return
        }

        createEntity(with: item, description: todoItemEntityDescription, context: context)
        
        do {
            try context.save()
        } catch {
            Log.error(FileCacheErrors.coreDataSaveContextError.localizedDescription)
        }
    }
    
    private func createEntity(with item: TodoItem, description: NSEntityDescription, context: NSManagedObjectContext) {
        let todoItemEntity = TodoItemEntity(entity: description, insertInto: context)
        
        todoItemEntity.id = item.id
        todoItemEntity.text = item.text
        todoItemEntity.importanceValue = item.importance
        todoItemEntity.done = item.isDone
        todoItemEntity.deadline = item.dateDeadline
        todoItemEntity.color = item.hexColor
        todoItemEntity.createdAt = item.dateСreation
        todoItemEntity.changingAt = item.dateChanging
    }
}

// MARK: - Enums

enum FileCacheErrors: String, Error {
    case directoryNotFound = "Директория файла не найдена"
    case jSONConvertationError = "При конвертацией JSON файла произошла ошибка"
    case pathToFileNotFound = "Путь до конечного файла не найден"
    case writeFileError = "При записи файла произошла ошибка"
    
    case sqliteConnectionCreateError = "Ошибка при создании SQLite базы данных"
    case sqliteInsertError = "Ошибка в SQLite insert элемента"
    case sqliteDeleteError = "Ошибка в SQLite delete элемента"
    case sqliteReplaceError = "Ошибка в SQLite replace элемента"
    case sqliteSaveError = "Ошибка в SQLite сохранении элементов"
    
    case coredataContainerCreateError = "Ошибка при загрузке хранилища Coredata"
    case coreDataContainerNotFound = "CoreData container не найден"
    case coreDataModelDescriptionFailed = "Не удалось создать Description модели"
    case coreDataSaveContextError = "Не удалось сохранить изменения CoreData"
    case coreDataLoadFromContextError = "Не удалось загрузить данные из CoreData"
    case coreDataDeleteError = "Не удалось удалить элемент CoreData"
}

private extension FileCacheImp {
    enum FileFormat: String {
        case csv = ".csv"
        case json = ".json"
        case db = ".db"
    }
    
    enum Constants {
        static let csvHeaderFormat = "id;text;importance;date_deadline;is_done;date_creation;date_changing"
        static let csvLineSeparator = "/r/n"
        static let coreDataModelName = "TodoItemEntity"
    }
}
