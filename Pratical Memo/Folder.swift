//
//  Folder.swift
//  Pratical Memo
//
//  Created by Suis on 2025/12/06.
//

import Foundation
import SwiftData

@Model
final class Folder {
    var name: String
    var iconName: String
    var createdAt: Date
    
    // Relationship to Notes
    @Relationship(deleteRule: .cascade, inverse: \Note.folder)
    var notes: [Note]?
    
    init(name: String, iconName: String = "folder") {
        self.name = name
        self.iconName = iconName
        self.createdAt = Date()
        self.notes = []
    }
}
