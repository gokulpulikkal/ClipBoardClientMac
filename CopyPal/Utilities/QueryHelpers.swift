//
//  QueryHelpers.swift
//  CopyPal
//
//  Created by Gokul P on 01/09/24.
//

import Foundation
import SwiftData

extension StringItem {
    static func sortedByDate() -> FetchDescriptor<StringItem> {
        var fetch = FetchDescriptor<StringItem>()
        fetch.sortBy = [SortDescriptor(\StringItem.timestamp, order: .reverse)]
        return fetch
    }
}
