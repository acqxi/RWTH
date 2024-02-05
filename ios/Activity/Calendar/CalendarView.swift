//
//  CalendarView.swift
//  iTrackWorkout
//
//  Created by JieTing on 2024/1/29.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Binding var currentMonth: Date
    
    /// Titles for days of the week.
    private let daysOfWeek = DayOfWeek.all
    
    var body: some View {
        VStack{
            // Displaying days of the week.
            HStack {
                ForEach(daysOfWeek) { day in
                    Text(day.shortString)
                        .frame(maxWidth: .infinity)
                }
            }
            
            ScrollView{
                
                // Displaying month calendar.
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    // show empty day
                    let numOfEmptyCell = Int(numberOfEmptyCells(at: currentMonth))
                    ForEach(100..<100+numOfEmptyCell, id: \.self) { i in
                        VStack{
                            Text("")
                        }
                    }
                    
                    // show date
                    ForEach(1...daysInMonth(date: currentMonth), id: \.self) { day in
                        let dateInDay = Date.from(
                            year: Calendar.current.dateComponents([.year], from: currentMonth).year!,
                            month: Calendar.current.dateComponents([.month], from: currentMonth).month!,
                            day: day
                        )
                        DayView(date: dateInDay)
                        
                    }
                }
            }
        }
    }
}

struct DayView: View {
    var date: Date
    @Query var projects: [Project]
    @Query var stopwatchData: [StopwatchData]

    private var allTasks: [Task] {
        projects.flatMap { $0.tasks }
    }
    var tasksToday: [Task] {tasksInDay(date: date, allTasks: allTasks)}
    private var stopwatchDataToday: [StopwatchData] {
        let componentsOfDate = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return stopwatchData.filter { data in
            let componentsOfStopwatch = Calendar.current.dateComponents(
                [.day, .month, .year],
                from: data.completionDate
            )
            return componentsOfDate == componentsOfStopwatch
        }
    }

    var body: some View {
        let tasksOfToday = tasksToday
        let stopwatchOfToday = stopwatchDataToday
        let tasksDoneToday = tasksOfToday.filter { task in
            stopwatchOfToday.contains { $0.taskId == task.id }
        }
        NavigationLink(destination: TaskDetailPage(date: date)) {
            VStack {
                // show date
                Text("\(Calendar.current.dateComponents([.day], from: date).day!)")
                    .font(.system(size: 15))
                    .font(.headline)
                    .padding(4)
                    .background(
                        Calendar.current.isDate(date, inSameDayAs: Date.now) ? .accentColor.opacity(0.2) : Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .frame(maxWidth: .infinity)
                
                if !tasksOfToday.isEmpty {
                    TaskView(
                        text: "\(tasksDoneToday.count)/\(tasksOfToday.count)",
                        complete: tasksDoneToday.count == tasksOfToday.count
                    )
                }
                
                Spacer() // same height of dayView
            }
            .frame(height: 80) // fixed height
            .padding(4)
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
