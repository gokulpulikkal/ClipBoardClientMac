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

    var body: some View {
        Text("Hojsnfogaskjnfdb")
    }
}

#Preview {
    ClipboardList()
        .modelContainer(previewContainer)
}
