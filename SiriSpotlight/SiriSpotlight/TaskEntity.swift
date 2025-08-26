//
//  TaskEntity.swift
//  SiriSpotlight
//
//  Demonstrates a simple AppEntity for use with App Intents.
//

import AppIntents
import SwiftUI

enum TaskStatus: String, Codable, CaseIterable, Hashable {
    case inProgress = "In Progress"
    case completed = "Completed"
}

struct TaskEntity: AppEntity, Identifiable, Hashable {
    static var defaultQuery = TaskQuery()

    let id: UUID
    var title: String
    var status: TaskStatus = .inProgress

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Task")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: title))
    }
}

@MainActor
final class TaskStore: ObservableObject {
    static let shared = TaskStore()

    @Published var tasks: [TaskEntity]

    private init() {
        self.tasks = [
            TaskEntity(id: UUID(), title: "Buy milk", status: .inProgress),
            TaskEntity(id: UUID(), title: "Walk the dog", status: .inProgress)
        ]
    }

    func add(_ task: TaskEntity) {
        tasks.append(task)
    }

    @discardableResult
    func markCompleted(_ task: TaskEntity) -> Bool {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].status = .completed
            return true
        }
        return false
    }
}

