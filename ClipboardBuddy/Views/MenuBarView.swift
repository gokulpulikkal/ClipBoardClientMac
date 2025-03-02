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
    @Query(PasteboardItem.sortedByDate()) private var allItems: [PasteboardItem]
    @State var selection: Int?
    @AppStorage(UserDefaultsKeys.listItemLimitNumberKey.rawValue) private var limit = 20
    
    private var clipboardManager = ClipboardManager()

    var itemStringFetchDescriptor: FetchDescriptor<PasteboardItem> {
        var fetch = FetchDescriptor<PasteboardItem>()
        fetch.fetchLimit = limit
        fetch.sortBy = [SortDescriptor(\PasteboardItem.timestamp, order: .reverse)]
        return fetch
    }

    var body: some View {
        NavigationStack {
            DynamicQuery(itemStringFetchDescriptor) { items in
                VStack(spacing: 0) {
                    toolbar(items: items)
                        .padding([.top, .trailing], 15)

                    List(selection: $selection) {
                        if !items.isEmpty {
                            getItemsList(items: items)
                                .onAppear {
                                    #if os(macOS)
                                    NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsevent in
                                        if selection != nil {
                                            switch nsevent.keyCode {
                                            case 125: // arrow down
                                                selection = selection! < items.count ? selection! + 1 : 0
                                            case 126: // arrow up
                                                selection = selection! > 1 ? selection! - 1 : 0
                                            case 36: // Enter key
                                                // Handle the enter key press (perform the action you want here)
                                                addItemToPastBoard(item: items[selection ?? 0])
                                            default:
                                                break
                                            }
                                        } else {
                                            selection = 0
                                        }
                                        return nsevent
                                    }
                                    #endif
                                }
                        }
                    }
                    .padding(.vertical)

                    if items.isEmpty {
                        noItemsView
                    }
                }
            }
        }
    }

    func toolbar(items: [PasteboardItem]) -> some View {
        HStack {
            Spacer()
            #if os(macOS)
            SettingsLink {
                Image(systemName: "gear")
            }
            #endif
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
    }

    func getItemsList(items: [PasteboardItem]) -> some View {
        ForEach(items.indices, id: \.self) { index in
            HStack {
                getItemView(items[index])
                Spacer()
                HStack {
                    Button(action: {
                        addItemToPastBoard(item: items[index])
                        deleteItem(item: items[index])
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
    }
    
    @ViewBuilder
    func getItemView(_ item: PasteboardItem) -> some View {
        if let imageData = item.image, let image = Image(data: imageData) {
            HStack {
                image
                    .resizable()
                    .frame(width: 25, height: 25)
                Text(item.string)
            }
        } else {
            Text(item.string.trimmingCharacters(in: .whitespacesAndNewlines))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .help(Text(item.string))
        }
    }

    var noItemsView: some View {
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

    private func addItemToPastBoard(item: PasteboardItem) {
        Task {
            await clipboardManager.addItemToPasteboard(item)
        }
    }

    private func deleteItem(item: PasteboardItem) {
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
        .modelContainer(for: PasteboardItem.self, inMemory: true)
}
