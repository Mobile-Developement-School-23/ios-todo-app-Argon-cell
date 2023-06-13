import Foundation

//MARK: - Enum

enum Importance: String {
    case unimportant
    case ordinary
    case important
}

//MARK: - Struct

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let dateСreation: Date
    let dateChanging: Date?

    init(id: String = UUID().uuidString, text: String, importance: Importance, deadline: Date? = nil, isDone: Bool, dateСreation: Date = Date.init(), dateChanging: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.dateСreation = dateСreation
        self.dateChanging = dateChanging
    }
}

//MARK: - Extensions

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let js = json as? [String: Any] else { return nil }

        let importance = js["importance"] as? Importance ?? .ordinary
        let isDone = js["is_done"] as? Bool ?? false
        let deadline = (js["deadline"] as? Double).flatMap({ Date(timeIntervalSince1970: $0) })
        let dateChanging = (js["date_changing"] as? Double).flatMap({ Date(timeIntervalSince1970: $0) })

        guard let id = js["id"] as? String,
              let text = js["text"] as? String,
              let dateCreation = (js["date_creation"] as? Double).flatMap({ Date(timeIntervalSince1970: $0 )}) else {
            return nil
        }
        
        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        deadline: deadline,
                        isDone: isDone,
                        dateСreation: dateCreation,
                        dateChanging: dateChanging)
    }
    
    var json: Any {
        var jsonDict: [String: Any] = [:]
        
        jsonDict["id"] = self.id
        jsonDict["text"] = self.text
        if self.importance != .ordinary {
            jsonDict["importance"] = self.importance.rawValue
        }
        if let deadline = self.deadline {
            jsonDict["deadline"] = deadline.timeIntervalSince1970
        }
        jsonDict["is_done"] = self.isDone
        jsonDict["date_creation"] = self.dateСreation.timeIntervalSince1970
        if let dateChanging = self.dateChanging {
            jsonDict["date_changing"] = dateChanging.timeIntervalSince1970
        }

        return jsonDict
    }
}

extension TodoItem {
    static func parse(csv: String) -> TodoItem? {
        let columns = csv.components(separatedBy: ";")
        
        let id = String(columns[0])
        let text = String(columns[1])
        let importance = Importance(rawValue: columns[2]) ?? .ordinary
        let isDone = Bool(columns[4]) ?? false
        let deadline = Double(columns[3]).flatMap({ Date(timeIntervalSince1970: $0) })
        let dateChanging = Double(columns[6]).flatMap({ Date(timeIntervalSince1970: $0) })
        
        guard let dateCreation = Double(columns[5]).flatMap({ Date(timeIntervalSince1970: $0) }) else {
            return nil
        }
        
        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        deadline: deadline,
                        isDone: isDone,
                        dateСreation: dateCreation,
                        dateChanging: dateChanging
        )
    }
    
    var csv: String {
        var csvString: Array<String> = []
        
        csvString.append(self.id)
        csvString.append(self.text)
        if self.importance != .ordinary {
            csvString.append(self.importance.rawValue)
        } else {
            csvString.append("")
        }
        if let deadline = self.deadline {
            csvString.append(String(deadline.timeIntervalSince1970))
        } else {
            csvString.append("")
        }
        csvString.append(String(self.isDone))
        
        csvString.append(String(self.dateСreation.timeIntervalSince1970))
        if let dateChanging = self.dateChanging {
            csvString.append(String(dateChanging.timeIntervalSince1970))
        } else {
            csvString.append("")
        }
        
        return csvString.lazy.joined(separator: ";")
    }

}
