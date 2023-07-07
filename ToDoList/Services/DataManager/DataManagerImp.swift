import Foundation

class DataManagerImp: DataManager {
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
    func deleteElementLocally(_ item: TodoItem) -> [TodoItem] {
        storage.remove(item)
        try? storage.save(to: mainDataBaseFileName)
        return storage.getItems()
    }
    
    func updateElementLocally(_ item: TodoItem) -> [TodoItem] {
        storage.update(item)
        try? storage.save(to: mainDataBaseFileName)
        return storage.getItems()
    }
        
    func loadListLocally() -> [TodoItem] {
        try? storage.load(from: mainDataBaseFileName)
        if let dataDelegate = self.dataDelegate {
            dataDelegate(self.storage.getItems())
        }
        return storage.getItems()
    }
    
    func getListNetwork(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        network.getList { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let (loadedItems, loadedRevision)):
                    self.storage.update(loadedItems)
                    try? self.storage.save(to: mainDataBaseFileName)
                    self.network.updateRevision(loadedRevision)
                    self.storage.isDirty = false
                    completion(.success(loadedItems))
                case .failure(let error):
                    self.storage.isDirty = true
                    completion(.failure(error))
            }
        }
    }
    
    func updateListNetwork(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        network.updateList(with: storage.getItems()) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let (loadedItems, loadedRevision)):
                    self.storage.setItems(loadedItems)
                    try? self.storage.save(to: mainDataBaseFileName)
                    self.network.updateRevision(loadedRevision)
                    self.storage.isDirty = false
                    completion(.success(loadedItems))
                case .failure(let error):
                    self.storage.isDirty = true
                    completion(.failure(error))
            }
        }
    }
    
    func addElementNetwork(_ item: TodoItem) {
        if storage.isDirty {
            updateListNetwork { _ in
                if let dataDelegate = self.dataDelegate {
                    dataDelegate(self.storage.getItems())
                }
            }
        } else {
            network.createTodoItem(with: item.id, item: item) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                    case .success:
                        self.updateRevision(self.network.getRevision() + 1)
                    case .failure:
                        self.storage.isDirty = true
                }
                
                if let dataDelegate = self.dataDelegate {
                    dataDelegate(self.storage.getItems())
                }
            }
        }
    }
    
    func deleteElementNetwork(_ item: TodoItem) {
        if storage.isDirty {
            updateListNetwork { _ in
                if let dataDelegate = self.dataDelegate {
                    dataDelegate(self.storage.getItems())
                }
            }
        } else {
            network.deleteTodoItem(with: item.id) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                    case .success:
                        self.updateRevision(self.network.getRevision() + 1)
                        self.storage.isDirty = false
                    case .failure:
                        self.storage.isDirty = true
                }
                
                if let dataDelegate = self.dataDelegate {
                    dataDelegate(self.storage.getItems())
                }
            }
        }
    }
    
    func updateElementNetwork(_ item: TodoItem) {
        if storage.isDirty {
            updateListNetwork { _ in
                if let dataDelegate = self.dataDelegate {
                    dataDelegate(self.storage.getItems())
                }
            }
        } else {
            network.updateTodoItem(with: item.id, item: item) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                    case .success:
                        self.updateRevision(self.network.getRevision() + 1)
                        self.storage.isDirty = false
                    case .failure:
                        self.storage.isDirty = true
                }
                
                if let dataDelegate = self.dataDelegate {
                    dataDelegate(self.storage.getItems())
                }
            }
        }
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
    
    func addElementLocally(_ item: TodoItem) -> [TodoItem] {
        storage.add(item)
        try? storage.save(to: mainDataBaseFileName)
        return storage.getItems()
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
    
    func checkToken(_ clouser: @escaping ((Bool) -> Void)) {
        network.checkToken { result in
            switch result {
            case .success:
                clouser(true)
            case .failure:
                clouser(false)
            }
        }
    }
}
