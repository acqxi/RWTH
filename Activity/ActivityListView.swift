//
//  ActivityListView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//  Refactored and commented on by Yu-Ting on 27.01.24.
//

import SwiftUI
import SwiftData
import Charts

// Enum representing different timeframes for filtering
enum Timeframe {
    case daily, monthly, allTime
}

// View for displaying activity list
struct ActivityListView: View {
    @Query var tasks: [Task]
    @Query var stopwatchData: [StopwatchData]
    @State private var selectedTimeframe: Timeframe = .allTime
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                ActivityChart(tasks: tasks, data: calculateStopwatchData())
                TimeframeSelectionView(selectedTimeframe: $selectedTimeframe, selectedDate: $selectedDate, stopwatchData: stopwatchData)
            }
            .navigationTitle("Training Summary 🏋️")
        }
    }
    
    // Calculate stopwatch data based on the selected timeframe
    private func calculateStopwatchData() -> [(UUID, TimeInterval)] {
        let filteredData = filterStopwatchData()
        return aggregateStopwatchData(filteredData)
    }
    
    // Filter stopwatch data based on the selected timeframe
    private func filterStopwatchData() -> [StopwatchData] {
        let calendar = Calendar.current
        return stopwatchData.filter { data in
            switch selectedTimeframe {
            case .daily:
                return calendar.isDate(data.completionDate, equalTo: selectedDate, toGranularity: .day)
            case .monthly:
                return calendar.isDate(data.completionDate, equalTo: selectedDate, toGranularity: .month)
            case .allTime:
                return true
            }
        }
    }
    
    // Aggregate stopwatch data by task
    private func aggregateStopwatchData(_ data: [StopwatchData]) -> [(UUID, TimeInterval)] {
        data.reduce(into: [:]) { result, datum in
            result[datum.taskId, default: 0] += datum.totalInterval
        }
        .filter { $1 > 0 }
        .map { ($0.key, $0.value) }
    }
}

// Subview for displaying the activity chart
struct ActivityChart: View {
    var tasks: [Task]
    var data: [(UUID, TimeInterval)]
    
    var body: some View {
        Chart {
            ForEach(data, id: \.0) { (taskId, interval) in
                let taskName = tasks.first { $0.id == taskId }?.name ?? "Unknown"
                SectorMark(angle: .value("Stream", interval), angularInset: 3)
                    .foregroundStyle(by: .value("name", taskName))
                    .cornerRadius(7)
                    .annotation(position: .overlay) {
                        Text(interval.formattedTime())
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
            }
        }
    }
}

// Extension for formatting TimeInterval
extension TimeInterval {
    func formattedTime() -> String {
        let hours = Int(self) / 3600
        let minutes = Int(self) % 3600 / 60
        let seconds = Int(self) % 60
        return "\(hours > 0 ? "\(hours)h " : "")\(minutes > 0 ? "\(minutes)m " : "")\(seconds > 0 ? "\(seconds)s" : "")".trimmingCharacters(in: .whitespaces)
    }
}

// Subview for timeframe selection
struct TimeframeSelectionView: View {
    @Binding var selectedTimeframe: Timeframe
    @Binding var selectedDate: Date
    var stopwatchData: [StopwatchData]
    
    var body: some View {
        Group {
            timeframeSpecificPicker()
            generalTimeframePicker()
        }
    }
    
    // Picker specific to the timeframe (daily or monthly)
    private func timeframeSpecificPicker() -> some View {
        switch selectedTimeframe {
        case .daily:
            return DatePicker("Day to view", selection: $selectedDate, displayedComponents: .date).eraseToAnyView()
        case .monthly:
            return MonthPickerView(selectedDate: $selectedDate, stopwatchData: stopwatchData).eraseToAnyView()
        default:
            return EmptyView().eraseToAnyView()
        }
    }
    
    // General picker for selecting timeframe
    private func generalTimeframePicker() -> some View {
        Picker("Select Timeframe", selection: $selectedTimeframe) {
            Text("Daily").tag(Timeframe.daily)
            Text("Monthly").tag(Timeframe.monthly)
            Text("All Time").tag(Timeframe.allTime)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

// Extension for converting View to AnyView
extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}

// Subview for selecting month
struct MonthPickerView: View {
    @Binding var selectedDate: Date
    var stopwatchData: [StopwatchData]
    
    var body: some View {
        Picker("Month to view", selection: $selectedDate) {
            ForEach(uniqueMonthAndYears(), id: \.self) { monthAndYear in
                Text(monthAndYear.longString).tag(monthAndYear.date)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
    
    // Calculate unique month and year combinations
    private func uniqueMonthAndYears() -> [MonthAndYear] {
        Set(stopwatchData.map { MonthAndYear(from: $0.completionDate) })
            .sorted()
    }
}

struct MonthAndYear: Codable, Identifiable, Comparable, Hashable {
    static func < (lhs: MonthAndYear, rhs: MonthAndYear) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }
        return lhs.month < rhs.month
    }
    
    var month: Int
    var year: Int
    
    var id: Int64 { Int64(month) + Int64(year) * 12 }
    
    var date: Date {
        Calendar.current.date(from: DateComponents(
            year: year,
            month: month
        ))!
    }
    
    init(from date: Date) {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        self.year = components.year ?? 0
        self.month = components.month ?? 0
    }
    
    var longString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return dateFormatter.string(from: self.date)
    }
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
    
    
}

#Preview {
    ActivityListView()
}
