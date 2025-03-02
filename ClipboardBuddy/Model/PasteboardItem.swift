//
//  PasteboardItem.swift
//  ClipboardBuddy
//
//  Created by Gokul P on 2/20/25.
//
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import Foundation
import SwiftData
import SwiftUI

@Model
final class PasteboardItem: @unchecked Sendable {
    var string = ""
    var image: Data? = Data()
    var url: URL? = URL(string: "")
    var timestamp = Date()

    init(_ pasteboardItem: NSPasteboardItem) {
        if let imageData = pasteboardItem.data(forType: .tiff) {
            self.image = imageData
        } else if let imageData = pasteboardItem.data(forType: .png) {
            self.image = imageData
        } else if let fileURLData = pasteboardItem.data(forType: .fileURL),
                  let fileURLString = String(data: fileURLData, encoding: .utf8),
                  let url = URL(string: fileURLString),
                  let image = NSImage(contentsOf: url)
        {
            self.image = image.tiffRepresentation
            self.url = url
        }
        if let stringItem = pasteboardItem.string(forType: .string) {
            self.string = stringItem
        }
    }

    init(_ object: Any) {
        if let image = object as? PlatformImage {
            #if os(macOS)
            // Convert NSImage to PNG data for better compatibility
            if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
                self.image = bitmapRep.representation(using: .png, properties: [:])
            }
            #else
            self.image = image.pngData()
            #endif
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
        self.timestamp = Date()
    }
}
