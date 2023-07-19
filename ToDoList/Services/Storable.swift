import Foundation

protocol Storable {
    var isDirty: Bool { get set }
    var markeredToDeleteItems: [String: Int] { get set }
    var markeredToUpdateItems: [String: Int] { get set }
    
    func getItem(id: String) -> TodoItem?
    func getList() -> [TodoItem]
    
    func deleteElement(_ item: TodoItem)
    func addElement(_ item: TodoItem)
    func updateElement(_ item: TodoItem)
    
    func setList(_ items: [TodoItem])
    func mergeList(_ items: [TodoItem])
 
    func save() throws
    func load() throws
    
    func getStorageType() -> StorageType
}

enum StorageType {
    case json
    case csv
    case sqlite
    case coredata
}
