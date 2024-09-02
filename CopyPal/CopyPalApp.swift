//
//  CopyPalApp.swift
//  CopyPal
//
//  Created by Gokul P on 31/08/24.
//

import SwiftData
import SwiftUI

@main
struct CopyPalApp: App {
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
        Group {
//            WindowGroup {
//                ContentView()
//                    .onAppear(perform: {
//                        ClipboardWatcher.shared.startWatching(using: sharedModelContainer.mainContext)
//                    })
//            }
//            .commands {
//                CopyPalCommands()
//            }
//            .modelContainer(sharedModelContainer)

            MenuBarExtra("ClipBoard", systemImage: "list.clipboard", content: {
                ContentView()
                    .modelContainer(sharedModelContainer)
                    .onAppear(perform: {
                        ClipboardWatcher.shared.startWatching(using: sharedModelContainer.mainContext)
                    })
            })
            .menuBarExtraStyle(.window)
        }
    }
}
