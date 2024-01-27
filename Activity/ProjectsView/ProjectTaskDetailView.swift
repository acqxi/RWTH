//
//  ProjectTaskDetailView.swift
//  Activity
//
//  Created by Vivian Wang on 2024/1/24.
//

import SwiftUI

struct ProjectTaskDetailView: View {
    var project: Project
    var task: Task
    @State private var name: String = ""
    var body: some View {
        Form {
            
            Section(header: Text("Time")) {
                Text(task.startDate, style: .date)
            }
            
            
            Section(header: Text("Priority")) {
                Text("Priority:  \(task.priority)")
            }
            
            Section(header: Text("Repeat")) {
                ForEach(Array(task.repeatDays.sorted { $0.rawValue < $1.rawValue }), id: \.rawValue) {day in
                    Text(day.string)
                }
            }
            
            Section(header: Text("Tags")) {
                ForEach(task.tags, id: \.self) { tag in
                    Text(tag)
                }
            }
            

        }
        .navigationBarTitle(task.name)
        .navigationBarItems(
            trailing:
                NavigationLink(destination: EditTaskDetailView(exercise: project, name:task.name, startDate: task.startDate,priority: task.priority,repeatDays:task.repeatDays,tags: task.tags)) {
                    Text("Edit")
                }
        )
    }
}
