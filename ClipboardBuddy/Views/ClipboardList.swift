//
//  ClipboardList.swift
//  CopyPal
//
//  Created by Gokul P on 03/09/24.
//

// import AlertMessage
import SwiftData
import SwiftUI

struct ClipboardList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(StringItem.sortedByDate()) private var items: [StringItem]
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var showSnackBar = false
    @AppStorage(UserDefaultsKeys.listItemLimitNumberKey.rawValue) private var limit = 20

    var itemStringFetchDescriptor: FetchDescriptor<StringItem> {
        var fetch = FetchDescriptor<StringItem>()
        fetch.fetchLimit = limit
        fetch.sortBy = [SortDescriptor(\StringItem.timestamp, order: .reverse)]
        return fetch
    }

    private var columns = [
        GridItem(.adaptive(minimum: 350, maximum: 400), spacing: 15)
    ]

    var body: some View {
        NavigationStack {
            DynamicQuery(itemStringFetchDescriptor) { items in
                if !items.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(items) { item in
                                NavigationLink(destination: {
                                    DetailsView(stringItem: item)
                                }, label: {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(item.timestamp.formatted(date: .numeric, time: .standard))
                                            .font(.footnote)
                                            .opacity(0.7)
                                        HStack {
                                            Text(item.value.trimmingCharacters(in: .whitespacesAndNewlines))
                                                .lineLimit(2, reservesSpace: true)
                                                .help(Text(item.value))
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
                                })
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(.white.shadow(.drop(
                                    color: .black.opacity(0.3),
                                    radius: 3
                                ))))
                                .padding(.vertical, 5)
                            }
                        }
                        .animation(.spring, value: items)
                        .padding()
                    }
                } else {
                    Text("Clipboard is Empty!!")
                }
            }
        }
        .tint(.primary)
        #if os(iOS)
            .alertMessage(isPresented: $showSnackBar, type: .snackbar) {
                HStack {
                    Image(systemName: "checkmark.seal")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.white)
                        .padding()

                    Text("Copied successfully!")
                        .foregroundColor(.white)

                    Spacer()
                }
                .frame(width: 335, height: 65)
                .background(RoundedRectangle(cornerRadius: 10).fill(.green))
                .padding()
            }
        #endif
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

    private func addItemToPastBoard(item: StringItem) {
        ClipboardWatcher.shared.inAppPastingInProgress = true
        #if os(macOS)
        NSPasteboard.general.prepareForNewContents()
        _ = NSPasteboard.general.setString(item.value, forType: .string)
        #else
        _ = UIPasteboard.general.string = item.value
        #endif
        showSnackBar = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            showSnackBar = false
        }
    }
}

#Preview {
    ClipboardList()
        .modelContainer(previewContainer)
}
