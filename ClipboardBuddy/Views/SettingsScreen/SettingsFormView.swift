//
//  SettingsFormView.swift
//  ClipboardBuddy
//
//  Created by Gokul P on 13/10/24.
//

import SwiftUI
import SwiftData

struct SettingsFormView: View {
    @AppStorage("historyLimit") private var limit = 20
    @Query(StringItem.sortedByDate()) private var allItems: [StringItem]
    @Environment(\.modelContext) private var modelContext
    @State var showAlert: Bool = false

    var body: some View {
        Form {
            HStack {
                #if !os(macOS)
                Text("Limit History to")
                    .bold()
                #endif
                TextField("", value: $limit, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button(role: .destructive, action: {
                deleteAllItems()
            } , label: {
                Text("Clear all history")
            })
            .buttonStyle(.borderedProminent)
            .disabled(allItems.isEmpty)
        }
        .alert("Cleared all ClipBoard History!", isPresented: $showAlert, actions: {
        })
    }
    
    @MainActor
    private func deleteAllItems() {
        // The batch delete option is not working as expected.
        withAnimation {
            for item in allItems {
                modelContext.delete(item)
            }
            showAlert = true
        }
    }
}

#Preview {
    SettingsFormView()
}
