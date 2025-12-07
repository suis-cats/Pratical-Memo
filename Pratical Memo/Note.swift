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
    var deletedAt: Date? // Soft delete timestamp
    
    // Relationship to Folder
    var folder: Folder?
    @Attribute(.externalStorage) var images: [Data]?
    
    // AI Analysis
    var summary: String?
    
    init(title: String = "", content: String = "", folder: Folder? = nil, images: [Data]? = nil, summary: String? = nil) {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isPinned = false
        self.deletedAt = nil
        self.folder = folder
        self.images = images ?? []
        self.summary = summary
    }
}

