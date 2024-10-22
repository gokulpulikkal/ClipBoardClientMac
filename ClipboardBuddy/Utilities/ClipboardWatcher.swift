//
//  ClipboardWatcher.swift
//  CopyPal
//
//  Created by Gokul P on 02/09/24.
//

import Foundation
import SwiftData
import SwiftUI

final class ClipboardWatcher {

    static let shared = ClipboardWatcher()

    private init() {}

    private var timer: Timer?
    private var isWatching = false
    var inAppPastingInProgress = false
    
    var lastCopiedItem: StringItem?

    /// Inject the ModelContainer
    var modelContext: ModelContext?

    func startWatching(using modelContext: ModelContext) {
        guard !isWatching else {
            return
        } // Prevent starting multiple timers

        isWatching = true
        self.modelContext = modelContext
        #if os(macOS)
        var changeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let copiedString = NSPasteboard.general.string(forType: .string),
                  NSPasteboard.general.changeCount != changeCount, self.lastCopiedItem?.value != copiedString
            else {
                return
            }

            defer {
                changeCount = NSPasteboard.general.changeCount
            }
            Task {
                await self.addCopiedStringToModel(copiedString)
            }
        }
        #else
        var changeCount = UIPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let copiedString = UIPasteboard.general.string,
                  UIPasteboard.general.changeCount != changeCount, self.lastCopiedItem?.value != copiedString
            else {
                return
            }

            defer {
                changeCount = UIPasteboard.general.changeCount
            }
            Task {
                await self.addCopiedStringToModel(copiedString)
            }
        }
        #endif
    }

    func stopWatching() {
        timer?.invalidate()
        timer = nil
        isWatching = false
    }

    @MainActor
    private func addCopiedStringToModel(_ copiedString: String) {
        guard let context = modelContext, !inAppPastingInProgress else {
            inAppPastingInProgress = false
            return
        }

        let newClip = StringItem(timestamp: Date(), value: copiedString)
        context.insert(newClip)
        lastCopiedItem = newClip
        do {
            try context.save()
        } catch {
            print("Failed to save copied string: \(error)")
        }
    }
}
