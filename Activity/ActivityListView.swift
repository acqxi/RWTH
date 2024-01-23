//
//  ActivityListView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI
import Charts

struct ActivityListView: View {
    var body: some View {
        
        NavigationStack{
            VStack{
                Chart{
                    ForEach(MockData.RevenueStreams) {
                        stream in SectorMark(angle: .value("Stream", stream.value), angularInset: 3)
                        
                        
                            .foregroundStyle(by: .value("name", stream.name))
                        
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
