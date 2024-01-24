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
                            NavigationLink(destination: TaskDetailView(date: "\(day) \( DateFormatter.monthAndYear.string(from:currentMonth))", exerciseItems: [
                                ExerciseItem(name: "run", repetitions: 10, isCompleted: false),
                                ExerciseItem(name: "walk", repetitions: 20, isCompleted: false),
                                ExerciseItem(name: "boxing", repetitions: 30, isCompleted: false),
                            ])) {
                                DayView(date: currentMonth, day: day, tasks: Array(repeating: "0/3", count: 1))
                            
                            }
                            .buttonStyle(PlainButtonStyle())

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

            // show task
//            ForEach(tasks, id: \.self) { task in
//                TaskView(task: task)
//            }
            
            ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                
                    TaskView(task: task)
                
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
