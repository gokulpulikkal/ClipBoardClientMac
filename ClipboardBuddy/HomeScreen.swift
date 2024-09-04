//
//  HomeScreen.swift
//  CopyPal
//
//  Created by Gokul P on 03/09/24.
//

import SwiftUI

struct HomeScreen: View {
    @State private var selectedTab: ScreenTypes? = .Clipboard
    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $selectedTab) {
                Label(title: {
                    Text("Board")
                }, icon: {
                    Image(systemName: "list.clipboard")
                })
                .tag(ScreenTypes.Clipboard)

                Label(title: {
                    Text("Settings")
                }, icon: {
                    Image(systemName: "gear")
                })
                .tag(ScreenTypes.Settings)
                Label(title: {
                    Text("Info")
                }, icon: {
                    Image(systemName: "info.circle")
                })
                .tag(ScreenTypes.Info)
            }
            .navigationTitle("Clipboard Buddy")

        }, detail: {
            if let selectedTab {
                switch selectedTab {
                case .Clipboard:
                    ClipboardList()
                default:
                    Text("Coming Sooon!")
                }
            }
        })
    }
}

#Preview {
    HomeScreen()
}
