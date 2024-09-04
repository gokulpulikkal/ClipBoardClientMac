//
//  DetailsView.swift
//  ClipboardBuddy
//
//  Created by Gokul P on 03/09/24.
//

// import AlertMessage
import SwiftUI

struct DetailsView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State var showSnackBar = false

    var stringItem: StringItem

    var body: some View {
        ScrollView {
            Text(stringItem.value)
                .multilineTextAlignment(.leading)
                .padding()
        }
        #if os(iOS)
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing, content: {
                HStack {
                    Button(action: {
                        addItemToPastBoard(item: stringItem)
                    }, label: {
                        Image(systemName: "document.on.document")
                    })

                    Button(action: {
                        deleteItem(item: stringItem)
                    }, label: {
                        Image(systemName: "trash")
                    })
                }
            })
        })

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
            .frame(width: 435, height: 65)
            .background(RoundedRectangle(cornerRadius: 10).fill(.green))
        }
        #endif
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

    private func deleteItem(item: StringItem) {
        withAnimation {
            modelContext.delete(item)
            dismiss()
        }
    }
}

#Preview {
    DetailsView(stringItem: StringItem(timestamp: Date(), value: "Hello"))
}
