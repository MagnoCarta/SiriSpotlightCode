//
//  Routing.swift
//  SiriSpotlight
//
//  Extracts tasks from user activities so the app can deep link into detail views.
//

import CoreSpotlight
import SwiftUI

enum Router {
    @MainActor static func task(from activity: NSUserActivity) -> TaskEntity? {
        if activity.activityType == CSSearchableItemActionType,
           let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
           let uuid = UUID(uuidString: id) {
            return TaskStore.shared.tasks.first { $0.id == uuid }
        }

        if activity.activityType == "com.example.task.detail",
           let id = activity.userInfo?["id"] as? String,
           let uuid = UUID(uuidString: id) {
            return TaskStore.shared.tasks.first { $0.id == uuid }
        }

        return nil
    }
}

