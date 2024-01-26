//
//  NewExerciseView.swift
//  Activity
//
//  Created by Vivian Wang on 2024/1/24.
//

import SwiftUI
import SwiftData

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
