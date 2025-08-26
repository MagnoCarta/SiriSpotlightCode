//
//  DisambiguationDemoIntent.swift
//  SiriSpotlight
//
//  Demonstrates an intent that completes a task and shows how Siri handles disambiguation and confirmation.
//
import AppIntents

struct DisambiguationDemoIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Task"

    @Parameter(
        title: "Task",
        requestValueDialog: IntentDialog("Which task do you want to complete?")
    )
    var task: TaskEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Complete \(\.$task)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<TaskEntity> & ProvidesDialog {
        if await TaskStore.shared.markCompleted(task) {
            return .result(value: task, dialog: "Marked \(task.title) complete.")
        } else {
            throw IntentError("That task no longer exists.")
        }
    }
}
