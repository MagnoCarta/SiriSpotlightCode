//
//  SpotlightIndexer.swift
//  SiriSpotlight
//
//  Indexes tasks into Core Spotlight so they appear in system search.
//

import CoreSpotlight
import UniformTypeIdentifiers

enum SpotlightIndexer {
    /// Rebuilds the Spotlight index for all tasks in the store.
    @MainActor static func reindexAll() {
        let items = TaskStore.shared.tasks.map { task -> CSSearchableItem in
            let attributes = CSSearchableItemAttributeSet(contentType: .text)
            attributes.title = task.title
            return CSSearchableItem(
                uniqueIdentifier: task.id.uuidString,
                domainIdentifier: "tasks",
                attributeSet: attributes
            )
        }

        let index = CSSearchableIndex.default()
        index.deleteAllSearchableItems()
        index.indexSearchableItems(items) { error in
            if let error { print("Index error: \(error.localizedDescription)") }
        }
    }
}

