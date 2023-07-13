import Foundation

protocol FileCache: AnyObject {
    func saveToJSON(file name: String) throws
    func loadFromJSON(file name: String) throws
    
    func saveToCSV(file name: String) throws
    func loadFromCSV(file name: String) throws
}
