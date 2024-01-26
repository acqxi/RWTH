//
//  NewTaskView.swift
//  Activity
//
//  Created by Vivian Wang on 2024/1/24.
//

import SwiftUI
import SwiftData

struct NewTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context

    var exercise: Project
    @State private var name: String = ""
    @State private var startDate: Date = .now
    @State private var priority: Int = 2
    @State private var newTag: String = ""
    @State private var tags: [String] = []
    @State private var showNewTagPopup = false
    @State private var selectedDays:[Int] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Name")) {
                    TextField("", text: $name)
                    DatePicker("Start Date", selection: $startDate)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        Text("Meh").tag(1)
                        Text("Maybe").tag(2)
                        Text("Must").tag(3)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Tags")) {
                    ForEach(0..<tags.count, id: \.self) { index in
                        Text(tags[index])
                    }
                    Button(action: {
                        showNewTagPopup.toggle()
                    }) {
                        Text("Add tag")
                    }
                }
                Section(header: Text("Repeat")) {
                    List {
                        ForEach(1..<8, id: \.self) { day in
                            Toggle(isOn: Binding(
                                get: {
                                    self.selectedDays.contains(day)
                                },
                                set: {_ in
                                    if self.selectedDays.contains(day) {
                                        self.selectedDays.remove(at: day)
                                    } else {
                                        self.selectedDays.append(day)
                                    }
                                }
                            )) {
                                Text(self.dayName(for: day))
                            }
                        }
                    }
                    
                }
            }
        }
        .navigationBarTitle("New Task")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("Cancel") {
                dismiss()
            },
            trailing: Button("Save") {
                let newTask = Task(name: name, tags: tags, startDate: startDate, priority: 2, selectedDays: selectedDays)
                exercise.tasks.append(newTask)
                try! context.save()
                dismiss()
             }
        )
        .sheet(isPresented: $showNewTagPopup) {
            TagChoice(onTagsSelected: { selectedTags in
                showNewTagPopup = false
                tags.append(contentsOf: selectedTags)
            })
        }
    }
    private func toggleDaySelection(_ day: Int) {
            if let index = selectedDays.firstIndex(of: day) {
                selectedDays.remove(at: index)
            } else {
                selectedDays.append(day)
            }
        print(selectedDays)
        }
    private func dayName(for day: Int) -> String {
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
