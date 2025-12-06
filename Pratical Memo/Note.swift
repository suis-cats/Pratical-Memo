//
//  Note.swift
//  Pratical Memo
//
//  Created by Suis on 2025/12/06.
//

import Foundation
import SwiftData

@Model
final class Note {
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isPinned: Bool
    
    // Relationship to Folder
    var folder: Folder?
    
    init(title: String = "", content: String = "", folder: Folder? = nil) {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isPinned = false
        self.folder = folder
    }
}
