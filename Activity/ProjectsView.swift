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
            .toolbar {
                ToolbarItemGroup {
                    
                    Menu("Sort", systemImage: "arrow.up.arrow.down") {
                        Picker("Sort", selection: $sortOrder) {
                            Text("Name")
                                .tag(SortDescriptor(\Project.name))

                            Text("Priority")
                                .tag(SortDescriptor(\Project.priority, order: .reverse))

                            Text("Date")
                                .tag(SortDescriptor(\Project.startDate))
                        }
                        .pickerStyle(.inline)
                    }
                    
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
    var exercise: Project
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    let exercise = Project(name: name, startDate: .now, priority: 2)
                    context.insert(exercise)
                    try! context.save()
                    dismiss()
                }
            }
        }
    }

}

struct ProjectTaskDetailView: View {
    var task: Task

    var body: some View {
        Form {
            Section(header: Text("Task Name")) {
                Text(task.name)
                Text(task.startDate, style: .date)
                Text("Priority:  \(task.priority)")
            }
            
            Section(header: Text("Tags")) {
                ForEach(task.tags, id: \.self) { tag in
                    Text(tag)
                }
            }
        }
        .navigationBarTitle(task.name)
    }
}

struct EditTaskView: View {
    @State private var name: String = ""

    var task: Task

    var body: some View {
        Form {
            Section(header: Text("Task Name")) {
                Text(task.name)
                Text(task.startDate, style: .date)
                Text("Priority:  \(task.priority)")
            }
            
            Section(header: Text("Tags")) {
                ForEach(task.tags, id: \.self) { tag in
                    Text(tag)
                }
            }
        }
    }
}

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
                                Image(systemName: exercise.tasks[index].checked ? "checkmark.circle.fill" : "circle")
                                    .onTapGesture {
                                        // Toggle the checked state
                                        // Implement logic to update the model accordingly
                                    }
                                Spacer()
                                Text(exercise.tasks[index].name)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteTasks)
            }
            .font(.title)
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
                let newTask = Task(name: name, tags: tags, startDate: .now, priority: 2)
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


#Preview {
    ProjectsView()
}

#Preview {
    ProjectContentView(exercise: Project(
        name: "Sample Exercise",
        tasks: [
            Task(name: "Task 1", tags: ["Legs"], startDate: .now, priority: 2),
            Task(name: "Task 2", checked: true, tags: [], startDate: .now),
            Task(name: "Task 3", tags: [], startDate: .now)
        ], startDate: Date()
    ))
}
