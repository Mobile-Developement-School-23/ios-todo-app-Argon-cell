import Foundation

protocol FileCache: AnyObject {
    func saveToJSON() throws
    func loadFromJSON() throws
    
    func saveToCSV() throws
    func loadFromCSV() throws
    
    func saveToSqlite() throws
    func loadFromSqlite() throws
    
}
