//
//  ClipboardBuddyApp.swift
//  ClipboardBuddy
//
//  Created by Gokul P on 03/09/24.
//

import SwiftData
import SwiftUI

@main
struct ClipboardBuddyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            StringItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        #if os(macOS)
        MenuBarExtra("ClipBoard", systemImage: "list.clipboard", content: {
            MenuBarView()
                .modelContainer(sharedModelContainer)
                .onAppear(perform: {
                    ClipboardWatcher.shared.startWatching(using: sharedModelContainer.mainContext)
                })
        })
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsTabView()
        }
        
        
        #else
        // Handle all other cases
        WindowGroup {
            LaunchView()
                .modelContainer(sharedModelContainer)
//                .modelContainer(previewContainer)
                .onAppear(perform: {
                    ClipboardWatcher.shared.startWatching(using: sharedModelContainer.mainContext)
                })
        }
        #endif
    }
}
