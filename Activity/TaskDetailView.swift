//
//  TaskDetailView.swift
//  GymTime
//
//  Created by JieTing on 2024/1/15.
//

import SwiftUI

struct ExerciseItem {
    let id = UUID()
    var name: String
    var repetitions: Int
    var isCompleted: Bool
}

struct TaskDetailView: View {
    var date: Date // date
    var exerciseItems: [Task] // items

    var body: some View {
        let dateFormatter = { () -> DateFormatter in
            let df = DateFormatter()
            df.dateStyle = .medium
            return df
        }()
        
        VStack(alignment: .leading, spacing: 10) {
            ForEach(exerciseItems.indices, id: \.self) { index in
                exerciseItemView(exerciseItems[index])
            }
            
            if exerciseItems.isEmpty {
                Spacer()
                
                Text("No tasks for this day")
                    .font(.title)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .navigationBarTitle(dateFormatter.string(from: date), displayMode: .inline)
        .padding()
    }

    private func exerciseItemView(_ item: Task) -> some View {
        NavigationLink(destination: Stopwatch(taskId: UUID())) {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
//                    Text("times: \(item.repetitions)")
//                        .font(.subheadline)
                }
                Spacer()
                Image(systemName: item.checked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.checked ? .green : .gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}


#Preview {
    TaskDetailView(date: Date(), exerciseItems: [])
}
