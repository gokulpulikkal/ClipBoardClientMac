//
//  PreviewData.swift
//  CopyPal
//
//  Created by Gokul P on 03/09/24.
//


import SwiftUI
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: StringItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let dummyData: [StringItem] = [
            StringItem(timestamp: Date().addingTimeInterval(-3600), value: "First copied text"),
            StringItem(timestamp: Date().addingTimeInterval(-1800), value: "Second copied text"),
            StringItem(timestamp: Date().addingTimeInterval(-1200), value: "Third copied text"),
            StringItem(timestamp: Date().addingTimeInterval(-600), value: "Fourth copied text"),
            StringItem(timestamp: Date(), value: "Fifth copied text")
        ]
        for stringItem in dummyData {
            container.mainContext.insert(stringItem)
        }
        return container
    } catch {
        fatalError("Error creating the preview container!")
    }
}()
