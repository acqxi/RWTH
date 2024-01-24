//
//  CalendarView.swift
//  GymTime
//
//  Created by JieTing on 2024/1/15.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @State private var currentMonth = Date()
    private let calendar = Calendar.current

    // title
    private let daysOfWeek = DayOfWeek.all

    var body: some View {
        NavigationView {
            VStack {
                // Month change controler
                HStack {
                    Button(action: { self.changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text("\(currentMonth, formatter: DateFormatter.monthAndYear)")
                        .font(.headline)
                    Spacer()
                    Button(action: { self.changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
                
                // show week's title
                HStack {
                    ForEach(daysOfWeek) { day in
                        Text(day.shortString)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                ScrollView{
                    // month calendar
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                        // show empty day
                        let nofec = Int(numberOfEmptyCells(at: currentMonth))
                        ForEach(100..<100+nofec, id: \.self) { i in
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
            .padding([.leading, .trailing])
            .safeAreaPadding()
        }
    }

    // change month
    func changeMonth(by amount: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: amount, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    // calc how many days in a month
    func daysInMonth(date: Date) -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: date)
        return range?.count ?? 30
    }
    
    // calc how many days in first week before first day in the months
    func numberOfEmptyCells(at date: Date) -> Int {
        let firstDayOfMonth = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
        // Sunday is 1, Monday is 2, Tuesday is 3
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        // Add 5: Sunday is 6, Monday is 7, Tuesday is 8
        // Mod 7: Sunday is 6, Monday is 0, Tuesday is 1
        // If the first day of the month is Monday, we need 0 empty cells
        // If the first day of the month is Tuedsay, we need 1 empty cell
        // ...
        // If the first day of the month is Sunday, we need 6 empty cells
        return (weekday + 5) % 7 // cnt rest day in week
    }
}

struct DayView: View {
    var date: Date
    @Query var projects: [Project]
    @Query var stopwatchData: [StopwatchData]
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
        NavigationLink(destination: TaskDetailView(date: date, exerciseItems: tasksOfToday)) {
            VStack {
                // show date
                Text("\(Calendar.current.dateComponents([.day], from: date).day!)")
                    .font(.system(size: 15))
                    .font(.headline)
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
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
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TaskView: View {
    var text: String
    var complete: Bool

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(3)
            .frame(maxWidth: .infinity)
            .background(complete ? Color.green.opacity(0.3) : Color.blue.opacity(0.3))
            .cornerRadius(5)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}

extension DateFormatter {
    static let monthAndYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}
