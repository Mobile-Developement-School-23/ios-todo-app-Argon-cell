import Foundation
import SQLite
import CoreData

protocol FileCache: AnyObject {
    func saveToJSON() throws
    func loadFromJSON() throws
    
    func saveToCSV() throws
    func loadFromCSV() throws
    
    func createSqliteReference() throws -> Connection
    func saveToSqlite() throws
    func loadFromSqlite() throws
    
    func updateItemSqlite(_ item: TodoItem)
    func deleteItemSqlite(_ item: TodoItem)
    func insertItemSqlite(_ item: TodoItem)
    
    func createCoreDataReference() throws -> NSPersistentContainer
    func saveToCoreData() throws
    func loadFromCoreData() throws
    
    func insertItemCoreData(_ item: TodoItem)
}

//FileCache
