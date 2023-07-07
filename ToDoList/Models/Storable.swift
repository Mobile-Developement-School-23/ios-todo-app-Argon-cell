import Foundation

protocol Storable {
    var isDirty: Bool { get set }
    
    func getItems() -> [TodoItem]
    func add(_ item: TodoItem)
    
    func remove(_ item: TodoItem)
    func update(_ item: TodoItem)
    func update(_ items: [TodoItem])
    func save(to file: String) throws
    func load(from file: String) throws
    func setItems(_ items: [TodoItem])
}

enum StorageType {
    case json
    case csv
}
