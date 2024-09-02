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
    @State private var isPastingOperationInProgress = false

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
        .onAppear {
            watch {
                if !isPastingOperationInProgress {
                    addItem(value: $0)
                }
                isPastingOperationInProgress = false
            }
        }
    }

    private func addItemToPastBoard(item: StringItem) {
        isPastingOperationInProgress = true
        NSPasteboard.general.prepareForNewContents()
        let isSuccess = NSPasteboard.general.setString(item.value, forType: .string)
    }

    private func addItem(value: String) {
        withAnimation {
            let newItem = StringItem(timestamp: Date(), value: value)
            modelContext.insert(newItem)
        }
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

    func watch(using closure: @escaping (_ copiedString: String) -> Void) {
        let pasteboard = NSPasteboard.general
        var changeCount = pasteboard.changeCount

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let copiedString = NSPasteboard.general.string(forType: .string),
                  NSPasteboard.general.changeCount != changeCount
            else {
                return
            }

            defer {
                changeCount = NSPasteboard.general.changeCount
            }

            closure(copiedString)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: StringItem.self, inMemory: true)
}
