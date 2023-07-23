import Foundation
import CoreData

@objc(TodoItemEntity)
public class TodoItemEntity: NSManagedObject {

}

extension TodoItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemEntity> {
        return NSFetchRequest<TodoItemEntity>(entityName: "TodoItemEntity")
    }

    @NSManaged public var changingAt: Date?
    @NSManaged public var color: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deadline: Date?
    @NSManaged public var done: Bool
    @NSManaged public var id: String?
    @NSManaged public var importance: String?
    @NSManaged public var text: String?
    
    var importanceValue: Importance {
        get {
            return Importance(rawValue: importance ?? "") ?? .ordinary
        }
        set {
            importance = newValue.rawValue
        }
    }
}
