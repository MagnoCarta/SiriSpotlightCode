# Deep Linking

Spotlight results and other user activities launch the app with an
`NSUserActivity`. The `Router` helper inspects the activity to extract a
task identifier and returns the matching `TaskEntity`.

In `SiriSpotlightApp`, `onContinueUserActivity` passes activities to the
router and navigates to `TaskDetailView`.

1. `TaskDetailView` publishes an activity with the type
   `com.example.task.detail` and the task's identifier.
2. Spotlight entries embed the same identifier using
   `CSSearchableItemActivityIdentifier`.
3. `Routing.swift` understands both payloads so results and handoffs land
   on the correct screen.

