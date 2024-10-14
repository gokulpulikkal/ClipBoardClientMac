//
//  SettingsTabView.swift
//  ClipboardBuddy
//
//  Created by Gokul P on 12/10/24.
//

import SwiftUI

struct SettingsTabView: View {

    var body: some View {
        TabView {
            SettingsFormView()
                .tabItem {
                    Label("Storage", systemImage: "opticaldiscdrive")
                }
            VersionInfoView()
                .tabItem {
                    Label("Version", systemImage: "info.circle")
                }
        }
        .padding()
        .frame(width: 500, height: 250)
    }
}

#Preview {
    SettingsTabView()
}
