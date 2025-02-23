//
//  ClipboardChangeListenerUseCase.swift
//  ClipboardBuddy
//
//  Created by Gokul P on 2/21/25.
//

import Foundation
import SwiftData

final class ClipboardChangeListenerUseCase: @unchecked Sendable {

    private let modelContext: ModelContext?
    private let clipboardManager = ClipboardManager()

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        Task {
            await self.listenAndSaveChangesToPersistentStorage()
        }
    }

    private func listenAndSaveChangesToPersistentStorage() async {
        do {
            for try await pasteboardItem in await clipboardManager.clipboardChanges {
                await saveToSwiftData(pasteboardItem)
            }
        } catch {
            print("Error in getting clipboard changes!")
        }
    }

    @MainActor
    private func saveToSwiftData(_ pasteboardItem: PasteboardItem) async {
        guard let modelContext else {
            return
        }
        modelContext.insert(pasteboardItem)
        do {
            try modelContext.save()
            print("The context save was success!")
        } catch {
            print("Catched error on saving the context ")
        }
    }
}
