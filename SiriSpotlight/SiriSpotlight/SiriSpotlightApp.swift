//
//  SiriSpotlightApp.swift
//  SiriSpotlight
//
//  Created by Gilberto Magno on 22/08/25.
//

import SwiftUI
import CoreSpotlight

@main
struct SiriSpotlightApp: App {
    @StateObject private var taskStore = TaskStore.shared
    @State private var routedTask: TaskEntity?

    init() {
        MyAppShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .navigationDestination(item: $routedTask) { task in
                        TaskDetailView(task: task)
                    }
            }
            .environmentObject(taskStore)
            .onContinueUserActivity(CSSearchableItemActionType, perform: handle)
            .onContinueUserActivity("com.example.task.detail", perform: handle)
            .task {
                SpotlightIndexer.reindexAll()
            }
        }
    }

    private func handle(_ activity: NSUserActivity) {
        routedTask = Router.task(from: activity)
    }
}
