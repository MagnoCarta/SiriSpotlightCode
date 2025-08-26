//
//  CreateTaskIntent.swift
//  SiriSpotlight
//
//  Example AppIntent to create a new task.
//

import AppIntents

struct CreateTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Task"

    @Parameter(title: "Title")
    var title: String

    static var parameterSummary: some ParameterSummary {
        Summary("Create task named \(\.$title)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<TaskEntity> {
        let task = TaskEntity(id: UUID(), title: title, status: .inProgress)
        await TaskStore.shared.add(task)
        return .result(value: task)
    }
}

