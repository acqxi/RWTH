//
//  CalendarView.swift
//  GymTime
//
//  Created by JieTing on 2024/1/15.
//  Commented by Yu-Ting
//

import SwiftUI
import SwiftData

// MARK: - CalendarView Main View

/// Main calendar view for displaying and interacting with dates and tasks.
struct MainView: View {
    @State private var currentMonth = Date()
    @State private var styleIdx: Int = 0
    
    @Query var projects: [Project]

    var body: some View {
        /// Main navigation view for the calendar.
        NavigationStack {
            VStack {
                controlPanelView(styleIdx: $styleIdx, currentMonth: $currentMonth)
                
                if styleIdx == 1 {
                    ListView(currentMonth: $currentMonth)
                }
                else{
                    CalendarView(currentMonth: $currentMonth)
                }
            }
            .padding([.leading, .trailing])
            .safeAreaPadding()
        }
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
            .background(complete ? Color.green.opacity(0.2) : Color.accentColor.opacity(0.2))
            .cornerRadius(5)
    }
}

// MARK: - Preview Provider

#Preview{
    MainView()
}
