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
            VStack {
                List {
                    HStack {
                        Spacer()
                        Button(action: {
                            NSApplication.shared.terminate(nil)
                        }) {
                            Label("Quit", systemImage: "trash")
                        }
                        if !items.isEmpty {
                            Button(action: deleteAllItems) {
                                Label("Clear All History", systemImage: "trash")
                            }
                        }
                    }
                    .padding(.bottom, 5)
                    .listRowSeparator(.hidden)
                    if !items.isEmpty {
                        ForEach(items) { item in
                            NavigationLink {
                                Text(item.value)
                                    .padding()
                            } label: {
                                HStack {
                                    Text(item.value)
                                        .lineLimit(2)
                                    Spacer()
                                    HStack {
                                        Button(action: {
                                            addItemToPastBoard(item: item)
                                        }, label: {
                                            Image(systemName: "document.on.document")
                                        })

                                        Button(action: {
                                            deleteItem(item: item)
                                        }, label: {
                                            Image(systemName: "trash")
                                        })
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                .padding(.vertical)

                if items.isEmpty {
                    VStack {
                        Label(title: {
                            Text("Clipboard is empty")
                        }, icon: {
                            Image(systemName: "clipboard")
                        })
                        .padding()
                        Spacer()
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

    private func deleteItem(item: StringItem) {
        withAnimation {
            modelContext.delete(item)
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
