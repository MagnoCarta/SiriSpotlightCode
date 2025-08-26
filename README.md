# Siri & Spotlight

This repository accompanies the **Foundations: App Intents in 15 Minutes** chapter. The Xcode project includes a minimal App
Intent that creates tasks and demonstrates the basic pieces of `AppEntity`, `EntityQuery`, and `AppIntent`.

## Running the sample

1. Open `SiriSpotlight.xcodeproj` in Xcode 16 or later.
2. Select an iOS 17 simulator and build & run.
3. Invoke **Create Task** via the Siri prompt or the debug console:
   ```swift
   await CreateTaskIntent(title: "Buy milk").perform()
   ```
4. Use the returned task in subsequent intents or queries.

The intent uses a simple in-memory `TaskStore`, so restarting the app resets the data.

## Trying Siri disambiguation

To experiment with voice invocation, disambiguation, and confirmation:

1. Create a couple of similar tasks in the debug console:
   ```swift
   await CreateTaskIntent(title: "Pay taxes").perform()
   await CreateTaskIntent(title: "Pay taxes for business").perform()
   ```
2. Invoke the **Complete Task** intent.
   - Voice: Ask Siri, "Complete my Pay taxes task."
   - Debug console:
     ```swift
      let task = TaskStore.shared.tasks.first!
     await DisambiguationDemoIntent(task: task).perform()
     ```
3. Siri disambiguates between the tasks and confirms before marking one complete.

## Assistant-friendly intents and on-screen context

To make the assistant more helpful, provide synonyms and on-screen context:

1. The `IntentSynonyms.json` file lists alternate phrases. Edit it to match the vocabulary your users expect.
2. `TaskDetailView` publishes an `NSUserActivity`. Open a task, then say "remind me tomorrow" to see the assistant act on the current screen.

## Spotlight indexing and deep linking

Surface tasks in system search and route results back into the app:

1. The app runs `SpotlightIndexer.reindexAll()` on launch to register tasks like "Buy milk" and "Walk the dog".
2. In the iOS simulator, pull down Spotlight and search for one of those task titles.
3. Selecting a result opens `TaskDetailView` via the helper in `Routing.swift`.

## End-to-end walkthrough

Run the complete Tiny Tasks demo to watch Siri, on-screen context, and Spotlight cooperate:

1. Open `SiriSpotlight.xcodeproj` and build & run on an iOS 17 simulator.
2. Create a task by voice (for example, "Create a task called Walk dog"), locate it in Spotlight, then return to the app and ask the assistant for a follow-up action.
3. In Xcode's test navigator, run `SiriFlowTests` and `DeepLinkTests` to verify voice creation and deep-link routing.
