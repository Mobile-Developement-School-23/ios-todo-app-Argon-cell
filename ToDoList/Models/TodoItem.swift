import Foundation
// import UIKit

// MARK: - Struct
public struct TodoItem {
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

// MARK: - Extensions
extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let js = json as? [String: Any] else { return nil }

        let importance = (js[JSONKeys.importance.rawValue] as? String).flatMap(Importance.init(rawValue: )) ?? .ordinary
        let isDone = js[JSONKeys.isDone.rawValue] as? Bool ?? false
        let dateDeadline = (js[JSONKeys.dateDeadline.rawValue] as? Double).flatMap { Date(timeIntervalSince1970: $0) }
        let hexColor = js[JSONKeys.hexColor.rawValue] as? String

        guard let id = js[JSONKeys.id.rawValue] as? String,
              let text = js[JSONKeys.text.rawValue] as? String,
              let dateCreation = (js[JSONKeys.dateСreation.rawValue] as? Double).flatMap({ Date(timeIntervalSince1970: $0) }),
              let dateChanging = (js[JSONKeys.dateChanging.rawValue] as? Double).flatMap({ Date(timeIntervalSince1970: $0) })

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

        jsonDict[JSONKeys.id.rawValue] = self.id
        jsonDict[JSONKeys.text.rawValue] = self.text
        jsonDict[JSONKeys.isDone.rawValue] = self.isDone
        jsonDict[JSONKeys.importance.rawValue] = self.importance.rawValue
        jsonDict[JSONKeys.dateСreation.rawValue] = Int(self.dateСreation.timeIntervalSince1970)
        jsonDict[JSONKeys.dateChanging.rawValue] = Int(dateChanging.timeIntervalSince1970)
        
        if let dateDeadline = self.dateDeadline {
            jsonDict[JSONKeys.dateDeadline.rawValue] = Int(dateDeadline.timeIntervalSince1970)
        }

        if let hexColor = self.hexColor {
            jsonDict[JSONKeys.hexColor.rawValue] = hexColor
        }
        jsonDict["last_updated_by"] = ""

        return jsonDict
    }
}

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

// MARK: - Enum

enum Importance: String {
    case unimportant = "low"
    case ordinary = "basic"
    case important
}

private enum JSONKeys: String {
    case id
    case text
    case importance
    case dateDeadline = "deadline"
    case isDone = "done"
    case hexColor = "color"
    case dateСreation = "created_at"
    case dateChanging = "changed_at"
//    case lastUpdatedBy = "last_updated_by"
}

private enum CSVSeparator: String {
    case comma = ","
    case semicolon = ";"
}
