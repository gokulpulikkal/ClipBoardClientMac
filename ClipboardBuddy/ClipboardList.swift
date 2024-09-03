//
//  ClipboardList.swift
//  CopyPal
//
//  Created by Gokul P on 03/09/24.
//

import SwiftData
import SwiftUI

struct ClipboardList: View {
    @Environment(\.modelContext) private var modelContext
    @Query(StringItem.sortedByDate()) private var items: [StringItem]
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var columns = [
        GridItem(.adaptive(minimum: 350, maximum: 400), spacing: 15)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(item.timestamp.formatted(date: .numeric, time: .standard))
                            .font(.footnote)
                            .opacity(0.7)
                        HStack {
                            Text(item.value)
                                .lineLimit(3)
                                .help(Text(item.value))
                            Spacer()
                            HStack {
                                Button(action: {
                                    //                            addItemToPastBoard(item: item)
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
}

#Preview {
    ClipboardList()
        .modelContainer(previewContainer)
}
