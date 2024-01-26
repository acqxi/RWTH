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
                ForEach(task.selectedDays, id: \.self) {day in
                    Text(dayShortName(for: day))
                }

            }
        }
        .navigationBarTitle(task.name)
        .navigationBarItems(
            trailing: Button("Edit") {
            }
        )
        
    }
    private func dayShortName(for day: Int) -> String {
            switch day {
            case 1: return "Monday"
            case 2: return "Tuesday"
            case 3: return "Wednesday"
            case 4: return "Thursday"
            case 5: return "Friday"
            case 6: return "Saturday"
            case 7: return "Sunday"
            default: return ""
            }
        }
}
