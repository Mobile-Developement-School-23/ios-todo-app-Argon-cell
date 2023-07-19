import Foundation

enum Log {
    enum LogLevel {
        case info
        case warning
        case error
        
        fileprivate var prefix: String {
            switch self {
            case .info: return "INFO"
            case .warning: return "WARNING ⚠️"
            case .error: return "ERROR ❌"
            }
        }
    }
    struct Context {
        let file: String
        let function: String
        let line: Int
        var description: String {
            return "\((file as NSString).lastPathComponent):\(line) \(function)"
        }
    }
    
    static func info(_ message: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(level: .info, message: message.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    static func error(_ message: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(level: .error, message: message.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    static func warning(_ message: String, shouldLogContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(level: .warning, message: message.description, shouldLogContext: shouldLogContext, context: context)
    }
    
    fileprivate static func handleLog(level: LogLevel, message: String, shouldLogContext: Bool, context: Context) {
        var logComponents = ["[\(level.prefix)]"]
        
        if shouldLogContext {
            logComponents.append(context.description)
        }
        
        logComponents.append("- " + message)
    
        let fullString = logComponents.joined(separator: " ")
        
        #if DEBUG
        print(fullString)
        #endif
    }
}
