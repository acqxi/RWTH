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
    @State private var name: String
    @State private var oldname: String
    @State private var startDate: Date
    @State private var priority: Int
    @State private var newTag: String
    @State private var tags: [String]
    @State private var showNewTagPopup = false
    @State private var repeatDays = Set<DayOfWeek>()
    
    init(exercise: Project, name: String="", startDate: Date = .now,priority: Int = 2,newTag: String = "",repeatDays:Set<DayOfWeek> = Set<DayOfWeek>(), tags: [String] = []) {
        self.exercise = exercise
        _oldname = State(initialValue: name)
        _name = State(initialValue: name)
        _startDate = State(initialValue: startDate)
        _priority = State(initialValue: priority)
        _newTag = State(initialValue: newTag)
        _repeatDays = State(initialValue: repeatDays)
        _tags = State(initialValue: tags)
    }
 
    var body: some View {

        let index :Int? = exercise.tasks.firstIndex(where: { $0.name == oldname })

        NavigationStack {
            Form {
                Section(header: Text("Task")) {
                    TextField("Name", text: $name)
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
                
                Section(header: Text("Repeat")){
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
            }
        }
        .navigationBarTitle(name)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("Cancel") {
                dismiss()
            },
            trailing: Button("Save") {
                dismiss()
                if let index{
                    let oldTaskchange = Task(name: name, tags: tags, startDate: startDate, priority: 2, repeatDays: repeatDays)
                    exercise.tasks[index] = oldTaskchange
                    try! context.save()
                }else{
                }
             }
        )
        .sheet(isPresented: $showNewTagPopup) {
            TagChoice(onTagsSelected: { selectedTags in
                showNewTagPopup = false
                tags.append(contentsOf: selectedTags)
            })
            .accentColor(settings?.accentColor.swiftuiAccentColor ?? .yellow)
        }
    }
}
