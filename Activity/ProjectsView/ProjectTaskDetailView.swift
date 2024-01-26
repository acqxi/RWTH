//
//  ProjectTaskDetailView.swift
//  Activity
//
//  Created by Vivian Wang on 2024/1/24.
//

import SwiftUI

struct ProjectTaskDetailView: View {
    var task: Task

    var body: some View {
        Form {
            Section(header: Text("Task Name")) {
                Text(task.name)
            }
            
            Section(header: Text("Time")) {
                Text(task.startDate, style: .date)
            }
            
            
            Section(header: Text("Priority")) {
                Text("Priority:  \(task.priority)")
            }
            
            Section(header: Text("Tags")) {
                ForEach(task.tags, id: \.self) { tag in
                    Text(tag)
                }
            }
            
            Section(header: Text("Repeat")) {
                ForEach(Array(task.repeatDays.sorted { $0.rawValue < $1.rawValue }), id: \.rawValue) {day in
                    Text(day.string)
                }
                
            }
        }
        .navigationBarTitle(task.name)
        .navigationBarItems(
            trailing: Button("Edit") {
            }
        )
    }
}
