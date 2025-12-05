//
//  Item.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
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
