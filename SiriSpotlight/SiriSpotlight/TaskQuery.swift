//
//  TaskQuery.swift
//  SiriSpotlight
//
//  Provides lookup and suggestions for TaskEntity.
//

import AppIntents

struct TaskQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [TaskEntity] {
        await TaskStore.shared.tasks.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [TaskEntity] {
        await TaskStore.shared.tasks
    }
}

