//
//  utils.swift
//  iTrackWorkout
//
//  Created by JieTing on 2024/1/29.
//

import SwiftUI
import SwiftData

/// Function to calculate how many days in first week before first day in the months.
func numberOfEmptyCells(at date: Date) -> Int {
    let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
    /// Sunday is 1, Monday is 2, Tuesday is 3
    let weekday = Calendar.current.component(.weekday, from: firstDayOfMonth)
    /// Add 5: Sunday is 6, Monday is 7, Tuesday is 8
    /// Mod 7: Sunday is 6, Monday is 0, Tuesday is 1
    /// If the first day of the month is Monday, we need 0 empty cells
    /// If the first day of the month is Tuedsay, we need 1 empty cell
    /// ...
    /// If the first day of the month is Sunday, we need 6 empty cells
    return (weekday + 5) % 7 /// Count rest days in a week.
}


/// Function to calculate how many days in a month.
func daysInMonth(date: Date) -> Int {
    let range = Calendar.current.range(of: .day, in: .month, for: date)
    return range?.count ?? 30
}

func tasksInDay(date: Date, allTasks:[Task]) -> [Task] {
    let componentsOfDate = Calendar.current.dateComponents([.day, .month, .year], from: date)
    return allTasks.filter { task in
        if task.startDate > Calendar.current.date(byAdding: .day, value: 1, to: date)! {
            // Task starts after today, therefore we're not interested.
            return false
        }
        
        let componentsOfTask = Calendar.current.dateComponents([.day, .month, .year], from: task.startDate)
        if componentsOfDate == componentsOfTask {
            /// If the task starts today, then it is okay.
            return true
        }
        
        var weekdayOfDate = (Calendar.current.dateComponents([.weekday], from: date).weekday! + 6) % 7
        if weekdayOfDate == 0 { weekdayOfDate = 7 }
        let weekday = DayOfWeek(rawValue: weekdayOfDate)!
        if task.repeatDays.contains(weekday) {
            // The task repeats today, so it's okay.
            return true
        }
        
        /// The task doesn't repeat today, don't use it.
        return false
    }
}

// Extension and additional struct implementations (ListView, DayView, etc.) go here.

// MARK: - Date Formatter Extension

/// Extension to provide a custom date formatter for the month and year.// Extension to provide a custom date formatter for the month and year.
extension DateFormatter {
    static let monthAndYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}
