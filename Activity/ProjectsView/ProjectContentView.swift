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
                        NavigationLink(destination: ProjectTaskDetailView(task: exercise.tasks[index])) {
                            HStack {
                                Text(exercise.tasks[index].name)
                            }
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
        exercise.tasks.remove(atOffsets: offsets)
    }
}
