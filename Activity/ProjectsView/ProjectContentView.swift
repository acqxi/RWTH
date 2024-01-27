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
    @State private var selection = Set<UUID>()
    
    @State private var deleteDialogVisible = false
    
    @Environment(\.editMode) var editMode
    
    var body: some View {
        NavigationStack {
            List(exercise.tasks, selection: $selection) { task in
                NavigationLink(destination: ProjectTaskDetailView(project:exercise, task: task)) {
                    Text(task.name)
                }
            }
            
        }
        .navigationTitle(exercise.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if editMode!.wrappedValue == .inactive {
                        NavigationLink(destination: NewTaskView(exercise: exercise)) {
                            Image(systemName: "plus")
                        }
                    } else {
                        Button {
                            deleteDialogVisible = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .disabled(selection.isEmpty)
                        .confirmationDialog(
                            "Are you sure you want to delete \(selection.count) tasks?",
                            isPresented: $deleteDialogVisible,
                            titleVisibility: .visible
                        ) {
                            Button("Delete", role: .destructive) {
                                let tasksToDelete = exercise.tasks.filter { selection.contains($0.id) }
                                exercise.tasks.removeAll { selection.contains($0.id) }
                                for task in tasksToDelete {
                                    modelContext.delete(task)
                                }
                                selection.removeAll()
                            }
                        }
                    }
                    EditButton()
                }
            }
        }
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
