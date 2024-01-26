//
//  ActivityListView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI
import SwiftData
import Charts

struct ActivityListView: View {
    @Query var tasks: [Task]
    @Query var stopwatchData: [StopwatchData]
    var stopwatchDataPerTask: [(UUID, TimeInterval)] {
        var result: [UUID: TimeInterval] = [:]
        
        for datum in stopwatchData {
            result[datum.taskId] = (result[datum.taskId] ?? 0) + datum.totalInterval
        }
        
        return Array(
            result
                .keys
                .lazy
                // Store both id and time
                .map { key in (key, result[key]!) }
                // Only keep time intervals greater than 0
                .filter { (_, value) in value > 0 }
        )
    }
    
    var body: some View {
        
        NavigationStack{
            VStack{
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
                //
            }
            .navigationTitle("Training Summary 🏋️")
        }

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
