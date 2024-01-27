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
    @Query(FetchDescriptor<StopwatchData>()) var stopwatchDatum: [StopwatchData]
    @Query var projects: [Project]
    private var allTasks: [Task] {
        projects.flatMap { $0.tasks }
    }
    private var tasksToday: [Task] {
        let componentsOfDate = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return allTasks.filter { task in
            if task.startDate > Calendar.current.date(byAdding: .day, value: 1, to: date)! {
                // Task starts after today, therefore we're not interested
                return false
            }
            
            let componentsOfTask = Calendar.current.dateComponents([.day, .month, .year], from: task.startDate)
            if componentsOfDate == componentsOfTask {
                // If the task starts today, then it is okay
                return true
            }
            
            var weekdayOfDate = (Calendar.current.dateComponents([.weekday], from: date).weekday! + 6) % 7
            if weekdayOfDate == 0 { weekdayOfDate = 7 }
            let weekday = DayOfWeek(rawValue: weekdayOfDate)!
            if task.repeatDays.contains(weekday) {
                // The task repeats today, so it's okay
                return true
            }
            
            // The task doesn't repeat today, don't use it
            return false
        }
    }
    
    init(date: Date) {
        self.date = date
        let taskIds = tasksToday.map { $0.id }
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
            ForEach(tasksToday.indices, id: \.self) { index in
                exerciseItemView(tasksToday[index])
            }
            
            if tasksToday.isEmpty {
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

