//
//  NewTaskView.swift
//  Activity
//
//  Created by Vivian Wang on 2024/1/24.
//

import SwiftUI
import SwiftData

struct EditTaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }

    var exercise: Project
    @State var task: Task
    
    @State var showNewTagPopup = false
    
    init(exercise: Project, task: Task) {
        self.exercise = exercise
        self._task = State(wrappedValue: task)
    }
    
    private func taskBinding<T>(for keyPath: WritableKeyPath<Task, T>) -> Binding<T> {
        Binding(
            get: { self.task[keyPath: keyPath] },
            set: { newValue in
                self.task[keyPath: keyPath] = newValue
            }
        )
    }
 
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task")) {
                    TextField("Name", text: taskBinding(for: \.name))
                    DatePicker("Start Date", selection: taskBinding(for: \.startDate))
                }
                
                Section("Priority") {
                    Picker("Priority", selection: taskBinding(for: \.priority)) {
                        Text("Meh").tag(1)
                        Text("Maybe").tag(2)
                        Text("Must").tag(3)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Repeat")){
                    NavigationLink {
                        RepeatDaysChoice(repeatDays: taskBinding(for: \.repeatDays))
                    } label: {
                        HStack(alignment: .lastTextBaseline) {
                            Text("Repeat")
                            Spacer()
                            if task.repeatDays.isEmpty {
                                Text("Never")
                            } else if task.repeatDays == Set<DayOfWeek>([.monday, .tuesday, .wednesday, .thursday, .friday]) {
                                Text("Every Weekday")
                            } else if task.repeatDays == Set<DayOfWeek>([.saturday, .sunday]) {
                                Text("Every Weekend Day")
                            } else if task.repeatDays == Set(DayOfWeek.all) {
                                Text("Every Day")
                            } else {
                                Text(
                                    task.repeatDays
                                        .sorted(by: { $0.rawValue < $1.rawValue })
                                        .lazy
                                        .map { $0.shortString }
                                        .joined(separator: ", ")
                                )
                            }
                        }
                    }
                }
                
                Section(header: Text("Tags")) {
                    ForEach(0..<task.tags.count, id: \.self) { index in
                        Text(task.tags[index])
                    }
                    .onDelete { indexSet in
                        task.tags.remove(atOffsets: indexSet)
                    }
                    
                    Button(action: {
                        showNewTagPopup.toggle()
                    }) {
                        Text("Add tag")
                    }
                }
            }
        }
        .navigationBarTitle("Edit Task")
        .sheet(isPresented: $showNewTagPopup) {
            TagChoice(initial: task.tags, onTagsSelected: { selectedTags in
                showNewTagPopup = false
                task.tags.removeAll()
                task.tags.append(contentsOf: selectedTags)
            })
            .accentColor(settings?.accentColor.swiftuiAccentColor ?? .yellow)
        }
    }
}
