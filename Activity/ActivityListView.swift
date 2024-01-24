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
        
        return Array(result.keys.lazy.map { ($0, result[$0]!) }.filter { $0.1 > 0 })
    }
    
    var body: some View {
        
        NavigationStack{
            VStack{
                Chart{
                    ForEach(stopwatchDataPerTask, id: \.0) { (taskId, interval) in
                        SectorMark(angle: .value("Stream", interval), angularInset: 3)
                            .foregroundStyle(by: .value("name", tasks.first(where: { $0.id == taskId })?.name ?? "Unknown"))
                            .cornerRadius(7)
                    }
                }
            }
            .navigationTitle("Training Summary 🏋️")
        }
        
    }
    
    
}

#Preview {
    ActivityListView()
}

struct RevenueStream: Identifiable {
    
    let id = UUID()
    let name: String
    let value: Double
    
}

struct MockData{
    static var RevenueStreams: [RevenueStream] = [
        .init(name: "Leg", value: 13),
        .init(name: "Arm", value: 56),
        .init(name: "Chest", value: 30),
        .init(name: "Back", value: 18),
    
    ]
    
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
    
    
}
