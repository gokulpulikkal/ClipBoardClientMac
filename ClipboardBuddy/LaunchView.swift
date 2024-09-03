//
//  LaunchView.swift
//  CopyPal
//
//  Created by Gokul P on 03/09/24.
//

import SwiftUI

struct LaunchView: View {
    @State var showingSplash = true
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            if !showingSplash {
                HomeScreen()
                    .transition(.move(edge: .trailing))
            }

            if showingSplash {
                Text("Clipboard Buddy")
                    .multilineTextAlignment(.center)
                    .font(.system(size: horizontalSizeClass == .compact ? 40 : 70, weight: .heavy))
                    .bold()
                    .padding(.bottom, 30)
                    .task {
                        do {
                            try await createDelay()
                        } catch {
                            print("couldn't create delay!! \(error.localizedDescription)")
                        }
                        withAnimation(.easeInOut) {
                            showingSplash = false
                        }
                    }
            }
        }
    }

    func createDelay() async throws {
        try await Task.sleep(nanoseconds: UInt64(1.5 * Double(NSEC_PER_SEC)))
    }
}

#Preview {
    LaunchView()
        .modelContainer(previewContainer)
}
