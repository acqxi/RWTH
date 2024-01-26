//
//  ActivityListView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI
import SwiftData
import Charts

enum Timeframe {
    case daily, monthly, allTime
}

struct ActivityListView: View {
    @Query var tasks: [Task]
    @Query var stopwatchData: [StopwatchData]
    @State private var selectedTimeframe: Timeframe = .allTime
    @State private var selectedDate = Date()
    
    var filteredStopwatchData: [StopwatchData] {
        let calendar = Calendar.current
        return stopwatchData.filter{ data in
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

    var stopwatchDataPerTask: [(UUID, TimeInterval)] {
        var result: [UUID: TimeInterval] = [:]
        
        for datum in filteredStopwatchData {
            result[datum.taskId] = (result[datum.taskId] ?? 0) + datum.totalInterval
        }
        
        return Array(
            result
                .keys
                .lazy
                .map { key in (key, result[key]!) }
                .filter { (_, value) in value > 0 }
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Chart{
                    ForEach(stopwatchDataPerTask, id: \.0) { (taskId, interval) in
                        let taskName = tasks.first { $0.id == taskId }?.name ?? "Unknown"
                        let timeAsString = ({ () -> String in
                            var result = ""
                            var interval = Int64(interval)
                            if interval / 3600 > 0 {
                                result += "\(interval / 3600)h"
                                interval %= 3600
                            }
                            if interval / 60 > 0 {
                                result += "\(interval / 60)m"
                                interval %= 60
                            }
                            if interval < 3600 && interval > 0 {
                                result += "\(interval)s"
                            }
                            return result
                        })()
                        SectorMark(angle: .value("Stream", interval), angularInset: 3)
                            .foregroundStyle(by: .value("name", taskName))
                            .cornerRadius(7)
                            .annotation(position: .overlay){
                                Text(timeAsString)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                    }
                }
                
                switch selectedTimeframe {
                case .daily:
                    DatePicker(
                        "Day to view",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                case .monthly:
                    Picker("Month to view", selection: $selectedDate) {
                        let availableMonths = Set(stopwatchData
                            .lazy
                            .map { $0.completionDate }
                            .map { Calendar.current.dateComponents([.month, .year], from: $0) })
                            .map { MonthAndYear(month: $0.month!, year: $0.year!) }
                        let sortedMonths = Array(availableMonths.sorted())
                            
                        ForEach(sortedMonths) { monthAndYear in
                            Text(monthAndYear.longString).tag(monthAndYear.date)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                default:
                    EmptyView()
                }
                
                Picker("Select Timeframe", selection: $selectedTimeframe) {
                    Text("Daily").tag(Timeframe.daily)
                    Text("Monthly").tag(Timeframe.monthly)
                    Text("All Time").tag(Timeframe.allTime)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .navigationTitle("Training Summary 🏋️")
        }
    }
}

struct MonthAndYear: Codable, Identifiable, Comparable {
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
    
    var longString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return dateFormatter.string(from: self.date)
    }
}

#Preview {
    ActivityListView()
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
    
    
}
