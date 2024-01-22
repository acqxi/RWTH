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
    @Query(sort: [SortDescriptor(\Projects.priority, order: .reverse), SortDescriptor(\Projects.name)]) var exercises: [Projects]
    @State private var sortOrder = SortDescriptor(\Projects.name)
    
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
            .toolbar {
                Menu("Sort", systemImage: "arrow.up.arrow.down") {
                    Picker("Sort", selection: $sortOrder) {
                        Text("Name")
                            .tag(SortDescriptor(\Projects.name))

                        Text("Priority")
                            .tag(SortDescriptor(\Projects.priority, order: .reverse))

                        Text("Date")
                            .tag(SortDescriptor(\Projects.startDate))
                    }
                    .pickerStyle(.inline)
                }
            }
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

struct ExerciseCell: View {
    var exercise: Projects
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .overlay(
                Text(exercise.name)
                    .foregroundColor(.black)
            )
    }
}

struct NewExerciseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context

    @State private var name: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
               Section(header: Text("Project Name")) {
                  TextField("", text: $name)
               }
            }
        }
        .navigationBarTitle("New Project")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("Cancel") {
                dismiss()
            },
            trailing: Button("Save") {
                let exercise = Projects(name: name, startDate: .now, priority: 2)
                context.insert(exercise)
                try! context.save()
                dismiss()
            }
        )
    }

}

struct ProjectContentView: View {
    @Environment(\.modelContext) var context
    var exercise: Projects
    @State private var isEditing = false
    var body: some View {
        NavigationStack {
            List(exercise.tasks) { task in
                CheckView(
                    isChecked: Binding(
                        get: { return task.checked },
                        set: { newValue in
                            task.checked = newValue
                        }
                    ),
                    title: task.name
                )
            }
            .font(.title)
//            .onDelete { indexSet in
//                for index in indexSet {
//                    context.delete(exercise.tasks[index])
//                }
//            }
        }
        .navigationTitle(exercise.name)
        .navigationBarItems(
            trailing: HStack {
                NavigationLink(destination: {
                    NewTaskView(exercise: exercise)
                }) {
                    Image(systemName: "plus")
                }
                Button(action: {
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Done" : "Edit")
                }
            }
         )
         .environment(\.editMode, .constant(isEditing ? .active : .inactive))
    }
}

struct NewTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context

    var exercise: Projects
    @State private var name: String = ""
    @State private var startDate: Date = .now
    @State private var priority: Int = 2
    @State private var newTag: String = ""
    @State private var tags: [String] = []
    @State private var showNewTagPopup = false
    
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
            }
        }
        .navigationBarTitle("New Task")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("Cancel") {
                dismiss()
            },
            trailing: Button("Save") {
                let newTask = Task(name: name, tags: tags)
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
}

struct TagChoice: View {
    var onTagsSelected: ([String]) -> ()
    
    @Environment(\.modelContext) var modelContext
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }
    
    @State var selectedTags: [String] = []
    @State var newTagName: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    ForEach(settings?.availableTags ?? []) { tag in
                        HStack {
                            Image(systemName: selectedTags.contains(tag.name) ? "checkmark.square.fill" :  "squareshape")
                                .foregroundStyle(selectedTags.contains(tag.name) ? .red : .gray)
                            Text(tag.name)
                        }.onTapGesture {
                            if selectedTags.contains(tag.name) {
                                selectedTags.removeAll(where: { item in item == tag.name })
                            } else {
                                selectedTags.append(tag.name)
                            }
                        }
                    }
                }
                Spacer()
                HStack {
                    TextField("New tag", text: $newTagName)
                    Button(action: {
                        if let settings = settings {
                            settings.availableTags.append(Tag(name: newTagName))
                        } else {
                            let settings = Settings()
                            settings.availableTags.append(Tag(name: newTagName))
                            modelContext.insert(settings)
                        }
                        newTagName = ""
                    }) {
                        Image(systemName: "plus")
                    }.disabled(newTagName.isEmpty)
                }.padding()
            }
            .navigationTitle("Choose Tags")
            .navigationBarItems(
                leading: Button("Cancel") {
                    onTagsSelected([])
                },
                trailing: Button("Save") {
                    onTagsSelected(selectedTags)
                }.disabled(selectedTags.isEmpty)
            )
        }
        
    }
}

struct CheckView: View {
    @Binding var isChecked: Bool
    var title: String
    func toggle(){isChecked = !isChecked}
    var body: some View {
        HStack{
            Button(action: toggle) {
                Image(systemName: isChecked ? "checkmark.square" : "square")
            }
            Text(title)
        }
    }
}


//#Preview {
//    ProjectsView()
//}
//
//#Preview {
//    ProjectContentView(exercise: Projects(
//        name: "Sample Exercise",
//        tasks: [
//            Task(name: "Task 1", tags: []),
//            Task(name: "Task 2", checked: true, tags: []),
//            Task(name: "Task 3", tags: [])
//        ]
//    ))
//}
