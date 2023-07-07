import Foundation

protocol DataManager: AnyObject {
    var dataDelegate: (([TodoItem]) -> Void)? { get set }
    
    // MARK: - Storable methods
    @discardableResult
    func addElementLocally(_ item: TodoItem) -> [TodoItem]
    
    @discardableResult
    func deleteElementLocally(_ item: TodoItem) -> [TodoItem]
    
    @discardableResult
    func updateElementLocally(_ item: TodoItem) -> [TodoItem]
    
    func loadListLocally() -> [TodoItem]
    func storageIsDirty() -> Bool
    
    // MARK: - Network methods
    func getListNetwork(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func updateListNetwork(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    
    func addElementNetwork(_ item: TodoItem)
    func deleteElementNetwork(_ item: TodoItem)
    func updateElementNetwork(_ item: TodoItem)
    func checkElementNetwork(_ id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    
    func updateNetworkToken(_ token: String?)
    func updateRevision(_ revision: Revision)
    func checkToken(_ clouser: @escaping ((Bool) -> Void))
}
