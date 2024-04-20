//
//  Item.swift
//  ProgressiveAlarm
//
//  Created by Joaquim Menezes on 27/03/24.
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
