//
//  TaskDetailView.swift
//  GymTime
//
//  Created by JieTing on 2024/1/15.
//

import SwiftUI
import SwiftData

struct ExerciseItem {
    var name: String
    var repetitions: Int
    var isCompleted: Bool
}

struct TaskDetailView: View {
    var date: String // date
    var exerciseItems: [ExerciseItem] // items

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Date: \(date)")
                .font(.headline)
                .padding()

            ForEach(exerciseItems.indices, id: \.self) { index in
                exerciseItemView(exerciseItems[index])
            }

            Spacer()
        }
        .navigationBarTitle("task detail", displayMode: .inline)
        .padding()
    }

    private func exerciseItemView(_ item: ExerciseItem) -> some View {
        NavigationLink(destination: {
            
            return Stopwatch(taskId: UUID())
            
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    Text("times: \(item.repetitions)")
                        .font(.subheadline)
                }
                Spacer()
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}


#Preview {
    TaskDetailView(date: "2024/01/12", exerciseItems: [
        ExerciseItem(name: "First", repetitions: 10, isCompleted: true),
        ExerciseItem(name: "Second", repetitions: 20, isCompleted: false),
        ExerciseItem(name: "Third", repetitions: 30, isCompleted: false),
    ])
}
