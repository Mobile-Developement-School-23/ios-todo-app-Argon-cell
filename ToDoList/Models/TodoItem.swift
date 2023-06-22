import Foundation

// MARK: - Struct

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let dateDeadline: Date?
    let isDone: Bool
    let dateСreation: Date
    let dateChanging: Date?

    init(id: String = UUID().uuidString, text: String, importance: Importance, dateDeadline: Date? = nil, isDone: Bool = false, dateСreation: Date = Date(), dateChanging: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.dateDeadline = dateDeadline
        self.isDone = isDone
        self.dateСreation = dateСreation
        self.dateChanging = dateChanging
    }
}

// MARK: - Extensions

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let js = json as? [String: Any] else { return nil }

        let importance = js[JSONKeys.importance.rawValue] as? Importance ?? .ordinary
        let isDone = js[JSONKeys.isDone.rawValue] as? Bool ?? false
        let dateDeadline = (js[JSONKeys.dateDeadline.rawValue] as? Double).flatMap { Date(timeIntervalSince1970: $0) }
        let dateChanging = (js[JSONKeys.dateChanging.rawValue] as? Double).flatMap { Date(timeIntervalSince1970: $0) }

        guard let id = js[JSONKeys.id.rawValue] as? String,
              let text = js[JSONKeys.text.rawValue] as? String,
              let dateCreation = (js[JSONKeys.dateСreation.rawValue] as? Double).flatMap({ Date(timeIntervalSince1970: $0) })
        else {
            return nil
        }

        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        dateDeadline: dateDeadline,
                        isDone: isDone,
                        dateСreation: dateCreation,
                        dateChanging: dateChanging)
    }

    var json: Any {
        var jsonDict: [String: Any] = [:]

        jsonDict[JSONKeys.id.rawValue] = self.id
        jsonDict[JSONKeys.text.rawValue] = self.text
        if self.importance != .ordinary {
            jsonDict[JSONKeys.importance.rawValue] = self.importance.rawValue
        }
        if let dateDeadline = self.dateDeadline {
            jsonDict[JSONKeys.dateDeadline.rawValue] = dateDeadline.timeIntervalSince1970
        }
        jsonDict[JSONKeys.isDone.rawValue] = self.isDone
        jsonDict[JSONKeys.dateСreation.rawValue] = self.dateСreation.timeIntervalSince1970
        if let dateChanging = self.dateChanging {
            jsonDict[JSONKeys.dateChanging.rawValue] = dateChanging.timeIntervalSince1970
        }

        return jsonDict
    }
}

extension TodoItem {
    static func parse(csv: String) -> TodoItem? {
        let columns = csv.components(separatedBy: CSVSeparator.semicolon.rawValue)

        let id = String(columns[0])
        let text = String(columns[1])
        let importance = Importance(rawValue: columns[2]) ?? .ordinary
        let isDone = Bool(columns[4]) ?? false
        let dateDeadline = Double(columns[3]).flatMap { Date(timeIntervalSince1970: $0) }
        let dateChanging = Double(columns[6]).flatMap { Date(timeIntervalSince1970: $0) }

        guard !id.isEmpty, !text.isEmpty, let dateCreation = Double(columns[5]).flatMap({ Date(timeIntervalSince1970: $0) }) else {
            return nil
        }

        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        dateDeadline: dateDeadline,
                        isDone: isDone,
                        dateСreation: dateCreation,
                        dateChanging: dateChanging)
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
        if let dateChanging = self.dateChanging {
            csvDataArray.append(String(dateChanging.timeIntervalSince1970))
        } else {
            csvDataArray.append("")
        }

        return csvDataArray.lazy.joined(separator: CSVSeparator.semicolon.rawValue)
    }
}

// MARK: - Enum

enum Importance: String {
    case unimportant
    case ordinary
    case important
}

private enum JSONKeys: String {
    case id
    case text
    case importance
    case dateDeadline = "date_deadline"
    case isDone = "is_done"
    case dateСreation = "date_creation"
    case dateChanging = "date_changing"
}

private enum CSVSeparator: String {
    case comma = ","
    case semicolon = ";"
}
