//
//  CopyPalCommands.swift
//  CopyPal
//
//  Created by Gokul P on 31/08/24.
//

import SwiftData
import SwiftUI

struct CopyPalCommands: Commands {

    @Environment(\.modelContext) private var modelContext
    @Query private var items: [StringItem]

    var body: some Commands {
        SidebarCommands()

        CommandMenu("CopyPal") {
            Button("Copy Item") {
                if let item = items.first {
                    print("copied item \(item.value)")
                }
            }
            .keyboardShortcut("v", modifiers: [.command, .shift])
            .disabled(items.isEmpty)
        }
    }
}
