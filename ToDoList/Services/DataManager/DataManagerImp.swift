import Foundation

final class DataManagerImp: DataManager {
    // MARK: - Properties
    var storage: Storable
    var network: NetworkService
    
    var dataDelegate: (([TodoItem]) -> Void)?
    
    // MARK: - Inits
    init(storage: Storable, network: NetworkService) {
        self.storage = storage
        self.network = network
    }
    
    // MARK: - Public methods
    func deleteElementLocally(_ item: TodoItem) {
        storage.deleteElement(item)
        if storage.getStorageType() != .sqlite {
            saveListLocally()
        }
        sendChanges()
    }
    
    func updateElementLocally(_ item: TodoItem) {
        storage.updateElement(item)
        if storage.getStorageType() != .sqlite {
            saveListLocally()
        }
        sendChanges()
    }
    
    func addElementLocally(_ item: TodoItem) {
        storage.addElement(item)
        if storage.getStorageType() != .sqlite {
            saveListLocally()
        }
        sendChanges()
    }
    
    func getListLocally() -> [TodoItem] {
        return storage.getList()
    }
    
    func saveListLocally() {
        try? storage.save()
    }
    
    func loadListLocally() {
        try? storage.load()
    }
    
    func getListNetwork(completion: @escaping (Result<([TodoItem], Revision), Error>) -> Void) {
        network.getList { result in
            switch result {
                case .success(let result):
                    completion(.success(result))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func patchListNetwork(_ items: [TodoItem], completion: @escaping (Result<([TodoItem], Revision), Error>) -> Void) {
        network.updateList(with: items) { result in
            switch result {
                case .success(let result):
                    completion(.success(result))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func makeSynchronization() {
        getListNetwork { result in
            switch result {
                case .success(let (fetchedItems, fetchedRevision)):
                if Set(fetchedItems) != Set(self.storage.getList()) {
                        self.storage.mergeList(fetchedItems)
                        self.saveListLocally()
                        self.network.updateRevision(fetchedRevision)
                        let intersaction = Set(self.storage.getList()).intersection(Set(fetchedItems))
                        let union = Set(self.storage.getList()).union(intersaction)
                       
                        self.patchListNetwork(Array(union)) { result in
                            switch result {
                            case .success(let (mergedServerItems, mergedServerRevision)):
                                self.storage.markeredToUpdateItems = [:]
                                self.storage.markeredToDeleteItems = [:]
                                self.network.updateRevision(mergedServerRevision)
                                self.storage.setList(mergedServerItems)
                                self.saveListLocally()
                                self.storage.isDirty = false
                                self.sendChanges()
                            case .failure:
                                self.storage.isDirty = true
                                self.sendChanges()
                            }
                        }
                    } else {
                        self.network.updateRevision(fetchedRevision)
                        self.storage.isDirty = false
                        self.sendChanges()
                    }
                case .failure:
                    self.storage.isDirty = true
                self.sendChanges()
            }
        }
    }
    
    func addElementNetwork(_ item: TodoItem) {
        storage.markeredToUpdateItems[item.id] = 1
        makeSynchronization()
    }
    
    func deleteElementNetwork(_ item: TodoItem) {
//        if storage.isDirty {
        storage.markeredToDeleteItems[item.id] = 1
        makeSynchronization()
//        } else {
//            patchListNetwork(self.storage.getList()) { result in
//                switch result {
//                case .success(let (mergedServerItems, mergedServerRevision)):
//                    self.network.updateRevision(mergedServerRevision)
//                    self.storage.setList(mergedServerItems)
//                    self.saveListLocally()
//                    self.storage.isDirty = false
//                    self.sendChanges()
//                case .failure:
//                    self.storage.isDirty = true
//                    self.sendChanges()
//                }
//            }
//        }
    }
    
    func updateElementNetwork(_ item: TodoItem) {
        storage.markeredToUpdateItems[item.id] = 1
        makeSynchronization()
    }
    
    func checkElementNetwork(_ id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        network.getTodoItem(with: id) { result in
            switch result {
                case .success(let loadedItem):
                    completion(.success(loadedItem))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func updateNetworkToken(_ token: String?) {
        network.updateToken(token: token)
    }
    
    func updateRevision(_ revision: Revision) {
        network.updateRevision(revision)
    }
    
    func storageIsDirty() -> Bool {
        return storage.isDirty
    }
    
    func checkToken(_ completion: @escaping ((Bool) -> Void)) {
        network.checkToken { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    // MARK: - Private methods

    private func sendChanges() {
        if let dataDelegate = dataDelegate {
            dataDelegate(storage.getList())
        }
    }
}
