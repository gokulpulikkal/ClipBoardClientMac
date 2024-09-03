//
//  StringItem.swift
//  CopyPal
//
//  Created by Gokul P on 31/08/24.
//

import Foundation
import SwiftData

@Model
final class StringItem {
    var timestamp: Date = Date()
    var value: String = ""
    
    init(timestamp: Date, value: String) {
        self.timestamp = timestamp
        self.value = value
    }
}
