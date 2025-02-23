//
//  PasteboardItem.swift
//  ClipboardBuddy
//
//  Created by Gokul P on 2/20/25.
//

import AppKit
import Foundation
import SwiftData

@Model
final class PasteboardItem: @unchecked Sendable {
    var string: String = ""
    var image: Data? = Data()
    var url: URL? = URL(string: "")
    var timestamp: Date = Date()

    init(_ object: Any) {
        if let image = object as? NSImage {
            self.image = image.tiffRepresentation
        } else {
            self.image = nil
        }

        if let string = object as? NSString as? String {
            self.string = string
        } else {
            self.string = ""
        }

        if let url = object as? URL {
            self.url = url
        } else {
            self.url = nil
        }
        timestamp = Date()
    }
}
