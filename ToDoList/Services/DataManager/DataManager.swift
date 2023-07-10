import Foundation

protocol DataManager: AnyObject {
    var dataDelegate: (([TodoItem]) -> Void)? { get set }
    
    // MARK: - Storable methods
    func addElementLocally(_ item: TodoItem)
    func deleteElementLocally(_ item: TodoItem)
    func updateElementLocally(_ item: TodoItem)
    
    func loadListLocally()
    func saveListLocally()
    
    func getListLocally() -> [TodoItem]
    
    func storageIsDirty() -> Bool
    
    // MARK: - Network methods
    func getListNetwork(completion: @escaping (Result<([TodoItem], Revision), Error>) -> Void)
    func patchListNetwork(_ items: [TodoItem], completion: @escaping (Result<([TodoItem], Revision), Error>) -> Void)
    
    func addElementNetwork(_ item: TodoItem)
    func deleteElementNetwork(_ item: TodoItem)
    func updateElementNetwork(_ item: TodoItem)
    func checkElementNetwork(_ id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    
    func updateNetworkToken(_ token: String?)
    func updateRevision(_ revision: Revision)
    func checkToken(_ completion: @escaping ((Bool) -> Void))
    
    func makeSynchronization()
}
