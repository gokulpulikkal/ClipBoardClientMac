//
//  MenuBarView.swift
//  CopyPal
//
//  Created by Gokul P on 31/08/24.
//

import SwiftData
import SwiftUI

struct MenuBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(StringItem.sortedByDate()) private var allItems: [StringItem]
    @State var selection: Int?
    @AppStorage("historyLimit") private var limit = 20

    var itemStringFetchDescriptor: FetchDescriptor<StringItem> {
        var fetch = FetchDescriptor<StringItem>()
        fetch.fetchLimit = limit
        fetch.sortBy = [SortDescriptor(\StringItem.timestamp, order: .reverse)]
        return fetch
    }

    var body: some View {
        NavigationStack {
            DynamicQuery(itemStringFetchDescriptor) { items in
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        SettingsLink {
                            Image(systemName: "gear")
                        }
                        Button(action: {
                            #if os(macOS)
                            NSApplication.shared.terminate(nil)
                            #endif
                        }) {
                            Label("Quit", systemImage: "xmark.circle")
                        }
                        if !items.isEmpty {
                            Button(action: deleteAllItems) {
                                Label("Clear All History", systemImage: "trash")
                            }
                        }
                    }
                    .padding([.top, .trailing], 15)

                    List(selection: $selection) {
                        if !items.isEmpty {
                            ForEach(items.indices, id: \.self) { index in
                                HStack {
                                    Text(items[index].value)
                                        .lineLimit(2)
                                        .help(Text(items[index].value))
                                    Spacer()
                                    HStack {
                                        Button(action: {
                                            addItemToPastBoard(item: items[index])
                                        }, label: {
                                            Image(systemName: "document.on.document")
                                        })

                                        Button(action: {
                                            deleteItem(item: items[index])
                                        }, label: {
                                            Image(systemName: "trash")
                                        })
                                    }
                                }
                            }
                            .onDelete(perform: { indexSet in
                                withAnimation {
                                    for index in indexSet {
                                        modelContext.delete(items[index])
                                    }
                                }
                            })
                            .onAppear {
                                NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsevent in
                                    if selection != nil {
                                        if nsevent.keyCode == 125 { // arrow down
                                            selection = selection! < items.count ? selection! + 1 : 0
                                        } else {
                                            if nsevent.keyCode == 126 { // arrow up
                                                selection = selection! > 1 ? selection! - 1 : 0
                                            }
                                        }
                                    } else {
                                        selection = 0
                                    }
                                    return nsevent
                                }
                            }
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
    }

    private func addItemToPastBoard(item: StringItem) {
        ClipboardWatcher.shared.inAppPastingInProgress = true
        #if os(macOS)
        NSPasteboard.general.prepareForNewContents()
        _ = NSPasteboard.general.setString(item.value, forType: .string)
        #endif
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
            for item in allItems {
                modelContext.delete(item)
            }
        }
    }
}

#Preview {
    MenuBarView()
        .modelContainer(for: StringItem.self, inMemory: true)
}

struct DynamicQuery<Element: PersistentModel, Content: View>: View {
    let descriptor: FetchDescriptor<Element>
    let content: ([Element]) -> Content
    
    @Query var items: [Element]
    
    init(_ descriptor: FetchDescriptor<Element>, @ViewBuilder content: @escaping ([Element]) -> Content) {
        self.descriptor = descriptor
        self.content = content
        _items = Query(descriptor)
    }
    
    var body: some View {
        content(items)
    }
}
