//
//  ProjectsView.swift
//  Activity
//
//  Created by TimurSmoev on 1/10/24.
//

import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.modelContext) var context
    @Environment(\.editMode) var editMode
    @Query(sort: [SortDescriptor(\Project.priority, order: .reverse), SortDescriptor(\Project.name)]) var exercises: [Project]
    
    @State private var sortOrder = SortDescriptor(\Project.name)
    
    var body: some View {
        NavigationStack {
            
            List{
                ForEach(exercises) { exercise in
                    NavigationLink(destination: ProjectContentView(exercise: exercise)) {
                        ExerciseCell(exercise: exercise)
                    }
                    // TODO: Use .sheet()
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        context.delete(exercises[index])
                    }
                }
                .padding()
                                
            }
//            .toolbar {
//                ToolbarItemGroup {
//                    
//                    Menu("Sort", systemImage: "arrow.up.arrow.down") {
//                        Picker("Sort", selection: $sortOrder) {
//                            Text("Name")
//                                .tag(SortDescriptor(\Project.name))
//
//                            Text("Priority")
//                                .tag(SortDescriptor(\Project.priority, order: .reverse))
//
//                            Text("Date")
//                                .tag(SortDescriptor(\Project.startDate))
//                        }
//                        .pickerStyle(.inline)
//                    }
//                    
//                }
                
//            }
            .navigationTitle("Projects")
            .navigationBarItems(
                trailing:
                    NavigationLink(destination: NewExerciseView()) {
                        Image(systemName: "plus")
                    }
            )
        }
    }
}
