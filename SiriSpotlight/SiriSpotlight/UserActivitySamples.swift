import SwiftUI

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

