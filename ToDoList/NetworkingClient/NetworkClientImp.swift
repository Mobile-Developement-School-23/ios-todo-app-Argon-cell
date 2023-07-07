import Foundation

struct NetworkClientImp: NetworkClient {
    // MARK: - Properties

    private let urlSession: URLSession

    // MARK: - Lifecycle

    init(urlSession: URLSession) {
        self.urlSession = urlSession
        urlSession.configuration.timeoutIntervalForRequest = Constants.timeout
    }

    // MARK: - Public
    func processRetryListRequest(request: HTTPRequest, tryCount: Int, completion: @Sendable @escaping (Result<([TodoItem], Int), Error>) -> Void) -> Cancellable? {
        let delay = min(Double(Constants.minDelay * pow(1.5, Double(tryCount))), Constants.maxDelay)
        let totalDelay = delay * (1.0 + Constants.jitter)

        return processListRequest(request: request) { result in
            switch result {
                case .success(let success):
                    completion(.success(success))
                case .failure(let error):
                    if tryCount < Constants.maxAttempts {
                        if let httpError = error as? HTTPError {
                            switch httpError {
                                case .failed:
                                    DispatchQueue.global().asyncAfter(deadline: .now() + totalDelay) {
                                        processRetryListRequest(request: request, tryCount: tryCount + 1, completion: completion)
                                    }
                                case .serverSideError:
                                    DispatchQueue.global().asyncAfter(deadline: .now() + totalDelay) {
                                        processRetryListRequest(request: request, tryCount: tryCount + 1, completion: completion)
                                    }
                                default:
                                    completion(.failure(httpError))
                            }
                        } else {
                            completion(.failure(error))
                        }
                    } else {
                        processListRequest(request:  HTTPRequest(route: "\(NetworkServiceImp.Constants.baseurl)/list", headers: request.headers)) { result in
                            switch result {
                                case .success(let success):
                                    completion(.success(success))
                                case .failure(let failure):
                                    completion(.failure(error))
                            }
                        }
                    }
            }
        }
    }
    
    func processRetryItemRequest(request: HTTPRequest, tryCount: Int, completion: @escaping (Result<TodoItem, Error>) -> Void) -> Cancellable? {
        let delay = min(Double(Constants.minDelay * pow(1.5, Double(tryCount))), Constants.maxDelay)
        let totalDelay = delay * (1.0 + Constants.jitter)

        return processItemRequest(request: request) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let error):
                if tryCount < Constants.maxAttempts {
                    if let httpError = error as? HTTPError {
                        switch httpError {
                        case .failed:
                            DispatchQueue.global().asyncAfter(deadline: .now() + totalDelay) {
                                processRetryItemRequest(request: request, tryCount: tryCount + 1, completion: completion)
                            }
                        case .serverSideError:
                            DispatchQueue.global().asyncAfter(deadline: .now() + totalDelay) {
                                processRetryItemRequest(request: request, tryCount: tryCount + 1, completion: completion)
                            }
                        default:
                            completion(.failure(httpError))
                        }
                    }
                } else {
                    completion(.failure(HTTPError.retryCountToMuch))
                }
            }
        }
    }
    
    func processAuthRequest(request: HTTPRequest, completion: @escaping (Result<Bool, Error>) -> Void) -> Cancellable? {
        do {
            let urlRequest = try createUrlRequest(from: request)

            let task = self.urlSession.dataTask(with: urlRequest) { _, response, error in
                guard let response = response as? HTTPURLResponse
                else {
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(HTTPError.failedResponseUnwrapping))
                    }
                    return
                }
                let handledResponse = HTTPNetworkResponse.handleNetworkResponse(for: response)
                
                switch handledResponse {
                    case .success:
                        NetworkClientImp.executeCompletionOnMainThread {
                            completion(.success(true))
                        }
                    case .failure(let error):
                        NetworkClientImp.executeCompletionOnMainThread {
                            completion(.failure(error))
                        }
                }
            }
            task.resume()
            return task
        } catch {
            NetworkClientImp.executeCompletionOnMainThread {
                completion(.failure(HTTPError.failed))
            }
        }
        return nil
    }
    
    func processListRequest(request: HTTPRequest, completion: @escaping (Result<([TodoItem], Int), Error>) -> Void) -> Cancellable? {
        do {
            let urlRequest = try createUrlRequest(from: request)

            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(HTTPError.failed))
                    return
                }
                
                guard let response = response as? HTTPURLResponse,
                      let data = data
                else {
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(HTTPError.failedResponseUnwrapping))
                    }
                    return
                }

                guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let listTodoitems = jsonObject["list"] as? [Any],
                      let revision = jsonObject["revision"] as? Int
                else {
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(FileCacheErrors.jSONConvertationError))
                    }
                    return
                }
                
                let handledResponse = HTTPNetworkResponse.handleNetworkResponse(for: response)
               
                switch handledResponse {
                case .success:
                    var result: [TodoItem] = []
                    for singleUnwrappedData in listTodoitems {
                        if let parsedItem = TodoItem.parse(json: singleUnwrappedData) {
                            result.append(parsedItem)
                        } else {
                            NetworkClientImp.executeCompletionOnMainThread {
                                completion(.failure(FileCacheErrors.jSONConvertationError))
                            }
                        }
                    }

                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.success((result, revision)))
                    }

                case .failure(let error):
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
            return task
        } catch {
            NetworkClientImp.executeCompletionOnMainThread {
                completion(.failure(HTTPError.failed))
            }
        }
        return nil
    }
    
    func processItemRequest(request: HTTPRequest, completion: @escaping (Result<TodoItem, Error>) -> Void) -> Cancellable? {
        do {
            let urlRequest = try createUrlRequest(from: request)

            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                guard let response = response as? HTTPURLResponse,
                      let data = data
                else {
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(HTTPError.failedResponseUnwrapping))
                    }
                    return
                }
                let handledResponse = HTTPNetworkResponse.handleNetworkResponse(for: response)
                
                switch handledResponse {
                case .success:
                    guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let elementTodoItem = jsonObject["element"] else {
                        NetworkClientImp.executeCompletionOnMainThread {
                            completion(.failure(FileCacheErrors.jSONConvertationError))
                        }
                        return
                    }
                    
                    let result = TodoItem.parse(json: elementTodoItem)

                    if let result = result {
                        NetworkClientImp.executeCompletionOnMainThread {
                            completion(.success(result))
                        }
                    } else {
                        NetworkClientImp.executeCompletionOnMainThread {
                            completion(.failure(FileCacheErrors.jSONConvertationError))
                        }
                    }
                case .failure(let error):
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
            return task
        } catch {
            NetworkClientImp.executeCompletionOnMainThread {
                completion(.failure(HTTPError.failed))
            }
        }
        return nil
    }
    
    // MARK: - Private

    private func createUrlRequest(from request: HTTPRequest) throws -> URLRequest {
        guard let urlComponents = URLComponents(string: request.route) else {
            throw HTTPError.missingURL
        }

        guard let url = urlComponents.url else {
            throw HTTPError.missingURLComponents
        }

        var generatedRequest: URLRequest = .init(url: url)
        generatedRequest.httpMethod = request.httpMethod.rawValue
        generatedRequest.httpBody = request.body

        request.headers.forEach {
            generatedRequest.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        return generatedRequest
    }

    private static func executeCompletionOnMainThread(_ closure: @escaping () -> Void) {
        DispatchQueue.main.async {
            closure()
        }
    }
}

extension URLSessionDataTask: Cancellable {}

// MARK: - Nested types

extension NetworkClientImp {
    enum Constants {
        static let replaceOccurrencesOf: String = "+"
        static let replacingOccurrencesWith: String = "%2B"
        static let timeout: Double = 10.0
        static let jitterMinBound: Double = 0.0
        static let jitterMaxnBound: Double = 0.05
        static let maxDelay: Double = 120.0
        static let minDelay: Double = 2.0
        static let maxAttempts: Int = 2

        static var jitter: Double {
            return Double.random(in: jitterMinBound...jitterMaxnBound)

        }
    }
}
