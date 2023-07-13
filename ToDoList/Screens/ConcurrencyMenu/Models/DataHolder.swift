import Foundation

class DataHolder {
    var jsonValues: [Any] = []
    
    @discardableResult
    func update(by data: [Any]) -> Int {
        jsonValues += data
        return jsonValues.count
    }
}
