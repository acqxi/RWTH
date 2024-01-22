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
    @Query(sort: \Exercise.name) var exercises: [Exercise]
    var body: some View {
        NavigationView {
            
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
    var exercise: Exercise
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
        NavigationView {
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
                let exercise = Exercise(name: name)
                context.insert(exercise)
                try! context.save()
                dismiss()
            }
        )
    }

}

struct ProjectContentView: View {
    var exercise: Exercise
    @State private var isEditing = false
    var body: some View {
        NavigationView {
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

    var exercise: Exercise
    @State private var name: String = ""
    @State private var newTag: String = ""
    @State private var tags: [String] = []
    @State private var showNewTagPopup = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Name")) {
                    TextField("", text: $name)
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
        NavigationView {
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
                            var settings = Settings()
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
    ProjectContentView(exercise: Exercise(
        name: "Sample Exercise",
        tasks: [
            Task(name: "Task 1", tags: []),
            Task(name: "Task 2", checked: true, tags: []),
            Task(name: "Task 3", tags: [])
        ]
    ))
}
