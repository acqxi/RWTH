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
    
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }
    
    var exercise: Project
    @State private var name: String = ""
    @State private var startDate: Date = .now
    @State private var priority: Int = 2
    @State private var newTag: String = ""
    @State private var tags: [String] = []
    @State private var showNewTagPopup = false
    @State private var repeatDays = Set<DayOfWeek>()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task")) {
                    TextField("Name", text: $name)
                    if exercise.tasks.contains(where: { $0.name.localizedLowercase == name.localizedLowercase }) {
                        Text("A task with the same name already exists").foregroundStyle(.red)
                    }
                    DatePicker("Start Date", selection: $startDate)
                    NavigationLink {
                        RepeatDaysChoice(repeatDays: $repeatDays)
                    } label: {
                        HStack(alignment: .lastTextBaseline) {
                            Text("Repeat")
                            Spacer()
                            if repeatDays.isEmpty {
                                Text("Never")
                            } else if repeatDays == Set<DayOfWeek>([.monday, .tuesday, .wednesday, .thursday, .friday]) {
                                Text("Every Weekday")
                            } else if repeatDays == Set<DayOfWeek>([.saturday, .sunday]) {
                                Text("Every Weekend Day")
                            } else if repeatDays == Set(DayOfWeek.all) {
                                Text("Every Day")
                            } else {
                                Text(
                                    repeatDays
                                        .sorted(by: { $0.rawValue < $1.rawValue })
                                        .lazy
                                        .map { $0.shortString }
                                        .joined(separator: ", ")
                                )
                            }
                        }
                    }
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
                    .onDelete { indexSet in
                        tags.remove(atOffsets: indexSet)
                    }
                    Button(action: {
                        showNewTagPopup.toggle()
                    }) {
                        Text("Add tag")
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
                let newTask = Task(name: name, tags: tags, startDate: startDate, priority: 2, repeatDays: repeatDays)
                exercise.tasks.append(newTask)
                try! context.save()
                dismiss()
            }.disabled(name.isEmpty || exercise.tasks.contains { $0.name.localizedLowercase == name.localizedLowercase })
        )
        .sheet(isPresented: $showNewTagPopup) {
            TagChoice(initial: tags, onTagsSelected: { selectedTags in
                showNewTagPopup = false
                tags.removeAll()
                tags.append(contentsOf: selectedTags)
            })
            .accentColor(settings?.accentColor.swiftuiAccentColor ?? .yellow)
        }
    }
}
