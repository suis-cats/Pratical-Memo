//
//  Item.swift
//  Pratical Memo
//
//  Created by Suis on 2025/12/06.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
