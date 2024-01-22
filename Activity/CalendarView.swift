//
//  CalendarView.swift
//  GymTime
//
//  Created by JieTing on 2024/1/15.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentMonth = Date()
    private let calendar = Calendar.current

    // title
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

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
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // month calendar
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    // show empty day
                    ForEach(0..<numberOfEmptyCells(at: currentMonth), id: \.self) { _ in
                        Text("")
                    }
                    // show date
                    ForEach(1...daysInMonth(date: currentMonth), id: \.self) { day in
                        DayView(date: currentMonth, day: day, tasks: Array(repeating: "task", count: Int.random(in: 0...3)))
                    }
                }
            }
            .padding()
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
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        return (weekday - 1) % 7 // cnt rest day in week
    }
}

struct DayView: View {
    var date = Date()
    var day: Int
    var tasks: [String]

    var body: some View {
        VStack {
            // show date
            Text("\(day)")
                .font(.system(size: 15))
                .font(.headline)
                .padding(4)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(maxWidth: .infinity)

            
            ForEach(tasks, id: \.self) { task in
                NavigationLink(destination: TaskDetailView(date: "\(day) \( DateFormatter.monthAndYear.string(from:date))", exerciseItems: [
                                ExerciseItem(name: "run", repetitions: 10, isCompleted: false),
                                ExerciseItem(name: "walk", repetitions: 20, isCompleted: false),
                                ExerciseItem(name: "boxing", repetitions: 30, isCompleted: false),
                            ])) {
                                TaskView(task: task)
                            }
                        }

            Spacer() // same height of dayView
        }
        .frame(height: 120) // fixed height
        .padding(4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct TaskView: View {
    var task: String

    var body: some View {
        Text(task)
            .font(.caption)
            .padding(3)
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.3))
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
