//
//  TaskDetailView.swift
//  GymTime
//
//  Created by JieTing on 2024/1/15.
//

import SwiftUI
import SwiftData

struct ExerciseItem {
    let id = UUID()
    var name: String
    var repetitions: Int
    var isCompleted: Bool
}

struct TaskDetailView: View {
    var date: Date // date
    var exerciseItems: [Task] // items
    var maxViewDayCnt = 1 // use for count maxViewDate
    @Query(FetchDescriptor<StopwatchData>()) var stopwatchDatum: [StopwatchData]
    
    init(date: Date, exerciseItems: [Task]) {
        self.date = date
        self.exerciseItems = exerciseItems
        let taskIds = exerciseItems.map { $0.id }
        let viewDateComponents = Calendar.current.dateComponents(
            [.day, .month, .year],
            from: date
        )
        let minViewDate = Calendar.current.date(from: viewDateComponents)!
        let maxViewDate = Calendar.current.date(byAdding: .day, value: 1, to: minViewDate)!
        self._stopwatchDatum = Query(filter: #Predicate { stopwatchData in
            return minViewDate <= stopwatchData.completionDate && stopwatchData.completionDate < maxViewDate && taskIds.contains(stopwatchData.taskId)
        })
    }

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
        .navigationBarItems(
            trailing:
                NavigationLink(destination: NewExerciseView()) {
                    Image(systemName: "plus")
                }
        )
        .padding()
    }

    private func exerciseItemView(_ item: Task) -> some View {
        let stopwatchData = stopwatchDatum.filter { $0.taskId == item.id }.first
        
        return NavigationLink(destination: Stopwatch(taskId: item.id, date: date)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
//                    Text("times: \(item.repetitions)")
//                        .font(.subheadline)
                }
                Spacer()
                Image(systemName: stopwatchData != nil ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(stopwatchData != nil ? .green : .gray)
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
