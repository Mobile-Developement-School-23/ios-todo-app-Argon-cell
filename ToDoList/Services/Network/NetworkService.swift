import Foundation

protocol NetworkService: AnyObject {
    func getToken() -> String?
    func getRevision() -> Revision
    func updateToken(token: String?)
    func updateRevision(_ revision: Revision)
    
    func checkToken(completion: @escaping (Result<([TodoItem], Revision), Error>) -> Void)
    func getList(completion: @escaping (Result<([TodoItem], Revision), Error>) -> Void)
    func updateList(with items: [TodoItem], completion: @escaping (Result<([TodoItem], Revision), Error>) -> Void)
    func getTodoItem(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func createTodoItem(with id: String, item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func updateTodoItem(with id: String, item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func deleteTodoItem(with id: String, completion: @escaping (Result<TodoItem, Error>) -> Void)
}
