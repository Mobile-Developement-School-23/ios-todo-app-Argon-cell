import Foundation
import UIKit

final class NetworkServiceImp: NetworkService {
    // MARK: - Properties
    private let networkClient: NetworkClient
    private var token: String?
    private var revision: RevisionStorage = RevisionStorage()

    // MARK: - Inits
    init(networkClient: NetworkClient, token: String? = nil) {
        self.networkClient = networkClient
        self.token = token
    }
    
    // MARK: - Public methods
    func updateRevision(_ revision: Revision) {
        self.revision.update(revision)
        UserDefaults.standard.set(revision, forKey: "last_known_revision")
    }
    
    func updateToken(token: String?) {
        self.token = token
    }
    
    func getToken() -> String? {
        return token
    }
    
    func getRevision() -> Revision {
        return Int(self.revision.getCurrentRevision())!
    }
    
    func checkToken(completion: @escaping (Result<([TodoItem], Revision), Error>) -> Void) {
        networkClient.processListRequest(request: createGetListRequest(), completion: completion)
    }
    
    func getList(completion: @escaping (Result<([TodoItem], Revision), Error>) -> Void) {
        networkClient.processRetryListRequest(request: createGetListRequest(), tryCount: 0, completion: completion)
    }
    
    func updateList(with items: [TodoItem], completion: @escaping (Result<([TodoItem], Revision), Error>) -> Void) {
        networkClient.processRetryListRequest(request: createUpdateListRequest(with: items), tryCount: 0, completion: completion)
    }
    
    func getTodoItem(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        networkClient.processRetryItemRequest(request: createGetTodoItemRequest(with: id), tryCount: 0, completion: completion)
    }
    
    func createTodoItem(with id: String, item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        networkClient.processRetryItemRequest(request: createCreateItemRequest(with: id, item: item), tryCount: 0, completion: completion)
    }
    
    func updateTodoItem(with id: String, item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        networkClient.processRetryItemRequest(request: createUpdateItemRequest(with: id, item: item), tryCount: 0, completion: completion)
    }
    
    func deleteTodoItem(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        networkClient.processRetryItemRequest(request: createDeleteItemRequest(id), tryCount: 0, completion: completion)
    }
    
    // MARK: - Private
    private func createDeleteItemRequest(_ id: String) -> HTTPRequest {
        HTTPRequest(route: "\(Constants.baseurl)/\(Constants.listRouting)/\(id)",
                    headers: [Constants.authorizationHeader: "Bearer \(token ?? "")",
                              Constants.lastKnownRevisionHeader: revision.getCurrentRevision()],
                    httpMethod: .delete)
    }
    
    private func createUpdateItemRequest(with id: String, item: TodoItem) -> HTTPRequest {
        HTTPRequest(route: "\(Constants.baseurl)/\(Constants.listRouting)/\(id)",
                    headers: [Constants.authorizationHeader: "Bearer \(token ?? "")",
                              Constants.lastKnownRevisionHeader: revision.getCurrentRevision()],
                    body: try? JSONSerialization.data(withJSONObject: ["element": item.json]),
                    httpMethod: .put)
    }
    
    private func createCreateItemRequest(with id: String, item: TodoItem) -> HTTPRequest {
        HTTPRequest(route: "\(Constants.baseurl)/\(Constants.listRouting)",
                    headers: [Constants.authorizationHeader: "Bearer \(token ?? "")",
                              Constants.lastKnownRevisionHeader: revision.getCurrentRevision()],
                    body: try? JSONSerialization.data(withJSONObject: ["element": item.json]),
                    httpMethod: .post)
    }
    
    private func createGetTodoItemRequest(with id: String) -> HTTPRequest {
        HTTPRequest(route: "\(Constants.baseurl)/\(Constants.listRouting)/\(id)",
                    headers: [Constants.authorizationHeader: "Bearer \(token ?? "")"])
    }

    private func createGetListRequest() -> HTTPRequest {
        HTTPRequest(route: "\(Constants.baseurl)/\(Constants.listRouting)",
                    headers: [Constants.authorizationHeader: "Bearer \(token ?? "")"])
    }
    
    private func createUpdateListRequest(with items: [TodoItem]) -> HTTPRequest {
        return HTTPRequest(route: "\(Constants.baseurl)/\(Constants.listRouting)",
                           headers: [Constants.authorizationHeader: "Bearer \(token ?? "")",
                                     Constants.lastKnownRevisionHeader: revision.getCurrentRevision()],
                           body: try? JSONSerialization.data(withJSONObject: ["list": items.map({$0.json})]),
                           httpMethod: .patch)
    }
    
}

// MARK: - Nested types

extension NetworkServiceImp {
    enum Constants {
        static let baseurl: String = "https://beta.mrdekk.ru/todobackend"
        static let authorizationHeader: String = "Authorization"
        static let lastKnownRevisionHeader: String = "X-Last-Known-Revision"
        
        static let listRouting = "list"
        
    }
}
