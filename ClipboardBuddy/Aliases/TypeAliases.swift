//
//  TypeAliases.swift
//  ClipboardBuddy
//
//  Created by Gokul P on 2/23/25.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif


#if os(macOS)
typealias PlatformImage = NSImage
typealias Pasteboard = NSPasteboard

#else
typealias PlatformImage = UIImage
typealias Pasteboard = UIPasteboard
#endif
