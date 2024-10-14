//
//  SettingsView.swift
//  ClipboardBuddy
//
//  Created by Gokul P on 12/10/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("historyLimit") private var limit = 20

    var body: some View {
        TabView {
            Form {
                TextField("Limit History to", value: $limit, format: .number)
                    .textFieldStyle(.roundedBorder)
            }.tabItem {
                Label("Storage", systemImage: "opticaldiscdrive")
            }

            VStack {
                Text("AppVersion: 1.0.0")
            }.tabItem {
                Label("Version", systemImage: "info.circle")
            }
        }
        .padding()
        .frame(width: 500, height: 250)
    }
}

#Preview {
    SettingsView()
}
