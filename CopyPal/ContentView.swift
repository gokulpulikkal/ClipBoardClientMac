//
//  ContentView.swift
//  CopyPal
//
//  Created by Gokul P on 31/08/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(StringItem.sortedByDate()) private var items: [StringItem]

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text(item.value)
                    } label: {
                        HStack {
                            Text(item.value)
                                .lineLimit(2)
                            Spacer()
                            Button(action: {
                                addItemToPastBoard(item: item)
                            }, label: {
                                Image(systemName: "document.on.document")
                            })
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }.toolbar {
                ToolbarItem {
                    Button(action: deleteAllItems) {
                        Label("Clear", systemImage: "trash")
                    }
                }
            }
        }
    }

    private func addItemToPastBoard(item: StringItem) {
        ClipboardWatcher.shared.inAppPastingInProgress = true
        NSPasteboard.general.prepareForNewContents()
        _ = NSPasteboard.general.setString(item.value, forType: .string)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }

    @MainActor
    private func deleteAllItems() {
        // The batch delete option is not working as expected.
        withAnimation {
            for item in items {
                modelContext.delete(item)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: StringItem.self, inMemory: true)
}
