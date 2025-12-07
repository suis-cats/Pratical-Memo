import Foundation
import SwiftData

enum SidebarSelection: Hashable, Identifiable {
    case all
    case trash
    case folder(Folder)
    
    var id: String {
        switch self {
        case .all: return "all"
        case .trash: return "trash"
        case .folder(let folder): return String(describing: folder.persistentModelID)
        }
    }
    
    static func == (lhs: SidebarSelection, rhs: SidebarSelection) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all), (.trash, .trash):
            return true
        case (.folder(let f1), .folder(let f2)):
            return f1 == f2
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .all: hasher.combine("all")
        case .trash: hasher.combine("trash")
        case .folder(let folder): hasher.combine(folder)
        }
    }
}
