import AppIntents

struct MyAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] = [
        AppShortcut(
            intent: CreateTaskIntent(),
            phrases: [
                "Create task in \(.applicationName)",
                "Add task in \(.applicationName)"
            ],
            shortTitle: "Create Task",
            systemImageName: "plus"
        )
        ,
        AppShortcut(
            intent: DisambiguationDemoIntent(),
            phrases: [
                "Complete task in \(.applicationName)",
                "Finish task in \(.applicationName)"
            ],
            shortTitle: "Complete Task",
            systemImageName: "checkmark.circle"
        )
    ]
    
}

