import Foundation
// import UIKit


// MARK: - Struct
struct TodoItem: Equatable, Hashable, Identifiable {
    let id: String
    var text: String
    var importance: Importance
    var dateDeadline: Date?
    var isDone: Bool
    var dateСreation: Date
    var dateChanging: Date
    var hexColor: String?

    init(id: String = UUID().uuidString, text: String, importance: Importance, dateDeadline: Date? = nil, isDone: Bool = false, dateСreation: Date = Date(), dateChanging: Date = Date(), hexColor: String? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.dateDeadline = dateDeadline
        self.isDone = isDone
        self.dateСreation = dateСreation
        self.dateChanging = dateChanging
        self.hexColor = hexColor
    }
}

// MARK: - JSON extension
extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let js = json as? [String: Any] else { return nil }

        let importance = (js[CodingKeys.importance.rawValue] as? String).flatMap(Importance.init(rawValue: )) ?? .ordinary
        let isDone = js[CodingKeys.isDone.rawValue] as? Bool ?? false
        let dateDeadline = (js[CodingKeys.dateDeadline.rawValue] as? Double).flatMap { Date(timeIntervalSince1970: $0) }
        let hexColor = js[CodingKeys.hexColor.rawValue] as? String

        guard let id = js[CodingKeys.id.rawValue] as? String,
              let text = js[CodingKeys.text.rawValue] as? String,
              let dateCreation = (js[CodingKeys.dateСreation.rawValue] as? Double).flatMap({ Date(timeIntervalSince1970: $0) }),
              let dateChanging = (js[CodingKeys.dateChanging.rawValue] as? Double).flatMap({ Date(timeIntervalSince1970: $0) })
        else {
            return nil
        }

        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        dateDeadline: dateDeadline,
                        isDone: isDone,
                        dateСreation: dateCreation,
                        dateChanging: dateChanging,
                        hexColor: hexColor)
    }

    var json: Any {
        var jsonDict: [String: Any] = [:]

        jsonDict[CodingKeys.id.rawValue] = self.id
        jsonDict[CodingKeys.text.rawValue] = self.text
        jsonDict[CodingKeys.isDone.rawValue] = self.isDone
        jsonDict[CodingKeys.importance.rawValue] = self.importance.rawValue
        jsonDict[CodingKeys.dateСreation.rawValue] = Int(self.dateСreation.timeIntervalSince1970)
        jsonDict[CodingKeys.dateChanging.rawValue] = Int(dateChanging.timeIntervalSince1970)
        
        if let dateDeadline = self.dateDeadline {
            jsonDict[CodingKeys.dateDeadline.rawValue] = Int(dateDeadline.timeIntervalSince1970)
        }

        if let hexColor = self.hexColor {
            jsonDict[CodingKeys.hexColor.rawValue] = hexColor
        }
        jsonDict["last_updated_by"] = ""

        return jsonDict
    }
}

// MARK: - CSV extension

extension TodoItem {
    static func parse(csv: String) -> TodoItem? {
        let columns = csv.components(separatedBy: CSVSeparator.semicolon.rawValue)
        guard columns.count == 8 else { return nil }
        
        let id = String(columns[0])
        let text = String(columns[1])
        let importance = Importance(rawValue: columns[2]) ?? .ordinary
        let isDone = Bool(columns[4]) ?? false
        let dateDeadline = Double(columns[3]).flatMap { Date(timeIntervalSince1970: $0) }
        let hexColor = String(columns[7])

        guard !id.isEmpty,
              !text.isEmpty,
              let dateCreation = Double(columns[5]).flatMap({ Date(timeIntervalSince1970: $0) }),
              let dateChanging = Double(columns[6]).flatMap({ Date(timeIntervalSince1970: $0)}) else {
            return nil
        }

        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        dateDeadline: dateDeadline,
                        isDone: isDone,
                        dateСreation: dateCreation,
                        dateChanging: dateChanging,
                        hexColor: hexColor)
    }

    var csv: String {
        var csvDataArray: [String] = []

        csvDataArray.append(self.id)
        csvDataArray.append(self.text)
        if self.importance != .ordinary {
            csvDataArray.append(self.importance.rawValue)
        } else {
            csvDataArray.append("")
        }
        if let dateDeadline = self.dateDeadline {
            csvDataArray.append(String(dateDeadline.timeIntervalSince1970))
        } else {
            csvDataArray.append("")
        }
        csvDataArray.append(String(self.isDone))

        csvDataArray.append(String(self.dateСreation.timeIntervalSince1970))
        csvDataArray.append(String(dateChanging.timeIntervalSince1970))

        if let hexColor = self.hexColor {
            csvDataArray.append(hexColor)
        }

        return csvDataArray.lazy.joined(separator: CSVSeparator.semicolon.rawValue)
    }
}

// MARK: - SQLite extension

extension TodoItem {
    static func parse(table: [Any]) -> TodoItem? {
        guard let id = table[0] as? String,
              let text = table[1] as? String,
//              let _ = table[8] as? String,
              let dateCreation = (table[6] as? Int64).flatMap({ Date(timeIntervalSince1970: Double($0)) }),
              let dateChanging = (table[7] as? Int64).flatMap({ Date(timeIntervalSince1970: Double($0)) })
        else { return nil }
        
        let importance = (table[2] as? String).flatMap(Importance.init(rawValue: )) ?? .ordinary
        let dateDeadline = (table[3] as? Int64).flatMap { Date(timeIntervalSince1970: Double($0)) }
        let isDone = (table[4] as? String).flatMap { Int($0) == 1 } ?? false
        let hexColor = table[5] as? String

        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        dateDeadline: dateDeadline,
                        isDone: isDone,
                        dateСreation: dateCreation,
                        dateChanging: dateChanging,
                        hexColor: hexColor)
    }
    
    var sqlReplaceStatement: String {
        let dateDeadline = self.dateDeadline.flatMap({ String($0.timeIntervalSince1970)}) ?? "NULL"
        let isDone = self.isDone ? 1 : 0
        let dateCreation = Int64(self.dateСreation.timeIntervalSince1970)
        let dateChanging = Int64(self.dateChanging.timeIntervalSince1970)
        
        return "REPLACE INTO list (\(CodingKeys.sqlQuery)) VALUES ('\(self.id)', '\(self.text)', '\(self.importance)', \(dateDeadline), \(isDone), '\(self.hexColor ?? "NULL")', \(dateCreation), \(dateChanging), '')"
    }
    
    var sqlDeleteStatement: String {
        return "DELETE FROM list WHERE \(CodingKeys.id.rawValue) = '\(self.id)'"
    }
    
    var sqlInsertStatement: String {
        let dateDeadline = self.dateDeadline.flatMap({ String($0.timeIntervalSince1970)}) ?? "NULL"
        let isDone = self.isDone ? 1 : 0
        let dateCreation = Int64(self.dateСreation.timeIntervalSince1970)
        let dateChanging = Int64(self.dateChanging.timeIntervalSince1970)
        
        return "INSERT INTO list (\(CodingKeys.sqlQuery)) VALUES ('\(self.id)', '\(self.text)', '\(self.importance)', \(dateDeadline), \(isDone), '\(self.hexColor ?? "NULL")', \(dateCreation), \(dateChanging), '')"
    }
}

// MARK: - CoreData extension

extension TodoItem {
    static func parse(entity: TodoItemEntity) -> TodoItem? {
        guard let id = entity.id,
              let text = entity.text,
              let dateCreation = entity.createdAt,
              let dateChanging = entity.changingAt
        else { return nil }
        
        let importance = Importance(rawValue: entity.importance ?? "") ?? .ordinary
        
        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        dateDeadline: entity.deadline,
                        isDone: entity.done,
                        dateСreation: dateCreation,
                        dateChanging: dateChanging,
                        hexColor: entity.color)
    }
}

// MARK: - Enum

extension TodoItem {
    private enum CSVSeparator: String {
        case comma = ","
        case semicolon = ";"
    }
}

enum Importance: String {
    case unimportant = "low"
    case ordinary = "basic"
    case important
}

enum CodingKeys: String {
    case id
    case text
    case importance
    case dateDeadline = "deadline"
    case isDone = "done"
    case hexColor = "color"
    case dateСreation = "created_at"
    case dateChanging = "changed_at"
    case lastUpdatedBy = "last_updated_by"
    
    static let sqlQuery: String = """
    \(CodingKeys.id.rawValue),
    \(CodingKeys.text.rawValue),
    \(CodingKeys.importance.rawValue),
    \(CodingKeys.dateDeadline.rawValue),
    \(CodingKeys.isDone.rawValue),
    \(CodingKeys.hexColor.rawValue),
    \(CodingKeys.dateСreation.rawValue),
    \(CodingKeys.dateChanging.rawValue),
    \(CodingKeys.lastUpdatedBy.rawValue)
    """
}
