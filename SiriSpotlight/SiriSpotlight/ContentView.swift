//
//  ContentView.swift
//  SiriSpotlight
//
//  Created by Gilberto Magno on 22/08/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var taskStore: TaskStore

    var body: some View {
        TabView {
            List(taskStore.tasks.filter { $0.status == .inProgress }) { task in
                NavigationLink(task.title) {
                    TaskDetailView(task: task)
                }
            }
            .navigationTitle("In Progress")
            .tabItem { Label("In Progress", systemImage: "list.bullet") }

            List(taskStore.tasks.filter { $0.status == .completed }) { task in
                NavigationLink(task.title) {
                    TaskDetailView(task: task)
                }
            }
            .navigationTitle("Completed")
            .tabItem { Label("Completed", systemImage: "checkmark") }
        }
    }
}

#Preview {
    NavigationStack { ContentView().environmentObject(TaskStore.shared) }
}
