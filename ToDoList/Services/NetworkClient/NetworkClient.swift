import Foundation

protocol NetworkClient {
    @discardableResult
    func processAuthRequest(request: HTTPRequest, completion: @escaping (Result<Bool, Error>) -> Void) -> Cancellable?
    
    @discardableResult
    func processItemRequest(request: HTTPRequest, completion: @escaping (Result<TodoItem, Error>) -> Void) -> Cancellable?
    
    @discardableResult
    func processListRequest(request: HTTPRequest, completion: @escaping (Result<([TodoItem], Int), Error>) -> Void) -> Cancellable?
    
    @discardableResult
    func processRetryListRequest(request: HTTPRequest, tryCount: Int, completion: @escaping (Result<([TodoItem], Int), Error>) -> Void) -> Cancellable?
    
    @discardableResult
    func processRetryItemRequest(request: HTTPRequest, tryCount: Int, completion: @escaping (Result<TodoItem, Error>) -> Void) -> Cancellable?
}

protocol Cancellable {
    func cancel()
}
