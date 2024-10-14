//
//  DynamicQuery.swift
//  ClipboardBuddy
//
//  Created by Gokul P on 13/10/24.
//

import SwiftUI
import SwiftData

struct DynamicQuery<Element: PersistentModel, Content: View>: View {
    let descriptor: FetchDescriptor<Element>
    let content: ([Element]) -> Content

    @Query var items: [Element]

    init(_ descriptor: FetchDescriptor<Element>, @ViewBuilder content: @escaping ([Element]) -> Content) {
        self.descriptor = descriptor
        self.content = content
        _items = Query(descriptor)
    }

    var body: some View {
        content(items)
    }
}
