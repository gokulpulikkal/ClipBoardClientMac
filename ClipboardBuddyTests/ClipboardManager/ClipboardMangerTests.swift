//
//  ClipboardMangerTests.swift
//  ClipboardBuddyTests
//
//  Created by Gokul P on 2/20/25.
//

import SwiftUI
import Testing
@testable import ClipboardBuddy

struct ClipboardMangerTests {

    let clipboardManger = ClipboardManager()

    @Test
    func singleItemCopy() async throws {
//        let itemStringToCopy = "I'm Gokul"
//        try await withThrowingTaskGroup(of: Void.self) { group in
//            group.addTask {
//                print("Testing: Started reading item from pasteboard")
//                for try await pasteboardItem in await clipboardManger.clipboardChanges {
//                    print("Testing: reading item from pasteboard")
//                    #expect(itemStringToCopy == pasteboardItem.string)
//                    return
//                }
//            }
//            group.addTask {
//                NSPasteboard.general.prepareForNewContents()
//                _ = NSPasteboard.general.setString(itemStringToCopy, forType: .string)
//                print("Testing: added item to pasteboard")
//            }
//            try await group.waitForAll() // If any of the two parallel tasks throws an error, the whole method throws
//        }
    }

}
