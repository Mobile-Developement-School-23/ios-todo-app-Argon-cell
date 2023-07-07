import Foundation

typealias Revision = Int

class RevisionStorage {
    private var revision: Revision = 0
    
    func update(_ number: Revision) {
        revision = number
    }
    
    func getCurrentRevision() -> String {
        return "\(revision)"
    }
}
