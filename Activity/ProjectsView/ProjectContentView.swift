//
//  ProjectContentView.swift
//  Activity
//
//  Created by Vivian Wang on 2024/1/24.
//

import SwiftUI
import SwiftData

struct ProjectContentView: View {
    @Environment(\.modelContext) var modelContext
    
    var exercise: Project
    @State private var isEditing = false
    @Environment(\.editMode) var editMode
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(exercise.tasks.indices, id: \.self) { index in
                    if isEditing {
                        // Edit mode - show detail view for editing
                        NavigationLink(destination: EditTaskView(task: exercise.tasks[index])) {
                            Text(exercise.tasks[index].name)
                        }
                    }
                    else {
                        NavigationLink(destination: ProjectTaskDetailView(project:exercise,task: exercise.tasks[index])) {
                                Text(exercise.tasks[index].name)
                        }
                    }
                }
                .onDelete(perform: deleteTasks)
            }
        }
        .navigationTitle(exercise.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    NavigationLink(destination: NewTaskView(exercise: exercise)) {
                        Image(systemName: "plus")
                    }
                    EditButton()
                }
            }
        }
        .environment(\.editMode, editMode)
    }
    
    func deleteTasks(at offsets: IndexSet) {
        for offset in offsets {
            let task = exercise.tasks[offset]
            if let dataForTask = try? modelContext.fetch(FetchDescriptor<StopwatchData>()) {
                let filtered = dataForTask.filter { $0.taskId == task.id }
                for data in filtered {
                    modelContext.delete(data)
                }
            }
            modelContext.delete(task)
        }
        exercise.tasks.remove(atOffsets: offsets)
    }
}
