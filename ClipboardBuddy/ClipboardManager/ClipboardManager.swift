//
//  ClipboardManager.swift
//  ClipboardBuddy
//
//  Created by Gokul P on 2/20/25.
//

import Foundation
import SwiftUI

actor ClipboardManager {

    private let pasteboard: Pasteboard
    private let pollingInterval: Double
    private var observingTypeClass: [AnyClass]

    init(
        pasteboard: Pasteboard = .general,
        observingTypeClass: [AnyClass] = [PlatformImage.self, NSString.self, NSURL.self],
        pollingInterval: Double = 0.05
    ) {
        self.pasteboard = pasteboard
        self.pollingInterval = pollingInterval
        self.observingTypeClass = observingTypeClass
    }

    var clipboardChanges: AsyncThrowingStream<PasteboardItem, Error> {
        AsyncThrowingStream<PasteboardItem, any Error> { continuation in
            Task {
                var changeCount = pasteboard.changeCount
                repeat {
                    checkPasteboardForChanges(changeCount, continuation)
                    changeCount = pasteboard.changeCount
                    try await Task.sleep(for: .milliseconds(500))
                } while !Task.isCancelled
            }
        }
    }

    private func checkPasteboardForChanges(
        _ currentChangeCount: Int,
        _ continuation: AsyncThrowingStream<PasteboardItem, any Error>.Continuation
    ) {
        #if os(macOS)
        guard currentChangeCount != pasteboard.changeCount,
              let pasteboardObjects = pasteboard.readObjects(forClasses: observingTypeClass)
        else {
            return
        }
        #else
        guard currentChangeCount != pasteboard.changeCount else {
            return
        }
        let pasteboardObjects = getPasteboardObjects()

        #endif
        pasteboardObjects.forEach { object in
            continuation.yield(PasteboardItem(object))
        }
    }

    #if os(macOS)
    #else
    private func getPasteboardObjects() -> [Any] {
        if pasteboard.hasURLs {
            return pasteboard.urls ?? []
        }
        if pasteboard.hasImages {
            return pasteboard.images ?? []
        }
        if pasteboard.hasStrings {
            return pasteboard.strings ?? []
        }
        return []
    }
    #endif

}
