# Chapter - Siri & Spotlight
## Siri, Apple Intelligence, and Spotlight
In this chapter, we'll explore how your iOS applications can deeply integrate with Siri, leverage Apple Intelligence, and appear effectively in Spotlight searches. We'll cover practical usage, explain the @AssistantIntent attribute in detail, and demonstrate how to leverage NSUserActivity for rich, context-aware interactions.
## Understanding the Role of Siri, Apple Intelligence, and Spotlight

Siri has evolved significantly, moving beyond simple voice commands to proactively providing relevant information to users based on context, usage patterns, and preferences. Apple Intelligence aggregates this data, intelligently predicting user needs, and Spotlight acts as a bridge, connecting users directly to your app’s functionalities or content.

### Foundations: App Intents in 15 Minutes

App Intents provide the connective tissue that lets Siri, Spotlight, and other system surfaces talk to your code. In this section we build a minimal intent that creates a task. The pieces fit together like this:

1. **Define an entity.** `TaskEntity` identifies a piece of data Siri can reference. It conforms to `AppEntity`, supplies a `displayRepresentation`, and tracks whether the task is `.inProgress` or `.completed`.
2. **Query for entities.** `TaskQuery` searches the observable `TaskStore` so the intent can resolve identifiers and offer suggestions.
3. **Author an intent.** `CreateTaskIntent` exposes a single parameter for the task title, stores the new task, and returns it.

```swift
// CreateTaskIntent.swift
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
```

The app's interface reads from this store and separates tasks into **In Progress** and **Completed** tabs. Selecting a task opens a detail view with a button to finish it, moving it from the first tab to the second.

With these three files in place, run the project on an iOS 17 simulator. In the debugger console or via Siri, invoke "Create a task called <name>". The intent constructs a new `TaskEntity`, stores it, and returns a representation that Siri can announce. This small example demonstrates the core concepts you will use throughout the rest of the book.

### Siri: Voice Invocation, Disambiguation, Confirmation

With a working intent, the next step is to make it pleasant to speak. Siri interprets the intent's title and parameter names as the core invocation phrases, but you can refine the experience by providing prompts and spoken responses.

1. **Invocation phrases.** Keep titles short and action‑oriented. `DisambiguationDemoIntent` uses the title "Complete Task", so saying "Hey Siri, complete my 'Buy milk' task" maps directly to the intent.
2. **Disambiguation.** When a phrase matches multiple entities, Siri asks the user to choose. The `requestValueDialog` on the `task` parameter customizes that prompt.
3. **Confirmation.** By returning a dialog string, the intent controls what Siri says after performing the action.

```swift
// DisambiguationDemoIntent.swift
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
            return .result(value: task, dialog: "Marked \\(task.title) complete.")
        } else {
            throw IntentError("That task no longer exists.")
        }
    }
}
```

Run the project, create two tasks with similar names, and ask:

> "Complete my Pay taxes task."

Siri will present the matching tasks, let you pick one, and then confirm the completion.

### Apple Intelligence: Assistant-Friendly Intents & On-Screen Context

Apple Intelligence can reuse your intents across surfaces when you provide clear wording and on-screen clues. Two pieces make this work:

1. **Synonyms and localization hooks.** By supplying alternate phrases, the assistant understands user vocabulary. The `IntentSynonyms.json` file maps "task" to common synonyms like "todo" or "reminder".
2. **`NSUserActivity` for context.** When a user views a task, publish an activity with a title and deep-link identifier.

```swift
// UserActivitySamples.swift
struct TaskDetailView: View {
    @EnvironmentObject var taskStore: TaskStore
    var task: TaskEntity

    var body: some View {
        VStack {
            Text(task.title)
            if task.status == .inProgress {
                Button("Mark Complete") {
                    taskStore.markCompleted(task)
                }
            }
        }
        .userActivity("com.example.task.detail", isActive: true) { activity in
            activity.title = task.title
            activity.userInfo = ["id": task.id.uuidString]
        }
    }
}
```

Run the app, navigate to a task, and say "remind me tomorrow". The assistant uses the activity to resolve the current task and can schedule a follow-up without extra prompting.

### Spotlight: Index, Reindex, Deep Link

Spotlight lets users search your app's content system-wide and jump
straight into the right screen. Indexing a record is as simple as creating
a `CSSearchableItem` for each task.

```swift
// SpotlightIndexer.swift
import CoreSpotlight
import UniformTypeIdentifiers

enum SpotlightIndexer {
    static func reindexAll() {
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
```

Call `SpotlightIndexer.reindexAll()` after launch to register sample tasks.
Pull down system search, type a task name, and tap the result. The app must
handle the incoming `NSUserActivity` to route to the detail view:

```swift
// Routing.swift
import CoreSpotlight
import SwiftUI

enum Router {
    static func task(from activity: NSUserActivity) -> TaskEntity? {
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
```

`SiriSpotlightApp` wires this up using `onContinueUserActivity`, navigating
to `TaskDetailView` when a match is found. The combination of stable
identifiers and a single router keeps deep links working even after cold
launches or data refreshes.

### Checking Your Intents in Shortcuts and Spotlight

Before moving on, confirm that the system has registered your intents.

1. **Shortcuts** – On the simulator or device, open the Shortcuts app. In the App Shortcuts tab find *Tiny Tasks* and make sure actions like **Create Task** or **Complete Task** appear. If nothing shows up, verify your app calls `MyAppShortcuts.updateAppShortcutParameters()` at launch, run the app once, and then reopen Shortcuts.
2. **Spotlight** – With the app running, call `SpotlightIndexer.reindexAll()` and then pull down system search. Look for one of the task titles you added. If no result is returned, check the Xcode console for indexing errors or reset the simulator's Spotlight index.

These quick checks help verify that your intents are discoverable before shipping.

### End-to-End Walkthrough: The Tiny Tasks App

With the core pieces in place, glue them together in a tiny demo that
exercises voice, context, and search in one flow. The app's entry point
`SiriSpotlightApp` wires the existing intent, activity, and Spotlight
helpers into a single scene:

```swift
// SiriSpotlight/SiriSpotlight/SiriSpotlightApp.swift
@main
struct SiriSpotlightApp: App {
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
            .onContinueUserActivity(CSSearchableItemActionType, perform: handle)
            .onContinueUserActivity("com.example.task.detail", perform: handle)
            .task { SpotlightIndexer.reindexAll() }
        }
    }

    private func handle(_ activity: NSUserActivity) {
        routedTask = Router.task(from: activity)
    }
}
```

Running the app and invoking "Create a task called Walk dog" adds a new
entry through `CreateTaskIntent`. Searching "Walk dog" in Spotlight jumps
back into the detail screen thanks to the shared `Router`. On that screen,
asking "remind me tomorrow" lets the assistant act on the current task
using the published `NSUserActivity`.

Two lightweight tests exercise these flows. `SiriFlowTests` verifies that
the intent adds a task, while `DeepLinkTests` ensures an activity resolves
to the correct entity:

```swift
// SiriSpotlightTests/SiriFlowTests.swift
func testVoiceCreatesTask() async throws {
    TaskStore.shared.tasks = []
    let intent = CreateTaskIntent(title: "Walk dog")
    _ = try await intent.perform()
    XCTAssertEqual(TaskStore.shared.tasks.first?.title, "Walk dog")
}

// SiriSpotlightTests/DeepLinkTests.swift
func testActivityRoutesToTask() {
    let task = TaskEntity(id: UUID(), title: "Pay bills", status: .inProgress)
    TaskStore.shared.tasks = [task]
    let activity = NSUserActivity(activityType: "com.example.task.detail")
    activity.userInfo = ["id": task.id.uuidString]
    XCTAssertEqual(Router.task(from: activity)?.id, task.id)
}
```

By combining runtime behavior with repeatable tests, you now have a
complete picture of how App Intents surface across Siri, Apple
Intelligence, and Spotlight.

