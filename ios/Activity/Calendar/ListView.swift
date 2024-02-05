//
//  ListView.swift
//  iTrackWorkout
//
//  Created by JieTing on 2024/1/29.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Binding var currentMonth: Date
    @Query var projects: [Project]
    @Query var tags: [Tag]
    
    @State var isShowingPopover: Bool = false
    
    @State private var isSearching = false
    @State private var searchTerm = ""
    private var searchResults: [SearchResult] {
        var result: [Project: SearchResult] = [:]
        
        let lowercaseSearchTerm = searchTerm.localizedLowercase
        
        for project in projects {
            if project.name.localizedLowercase.contains(lowercaseSearchTerm) {
                result[project] = SearchResult(project: project, tasks: [], tags: [], findReasons: [.project])
            }
            for task in project.tasks {
                if task.name.localizedLowercase.contains(lowercaseSearchTerm) {
                    var sr = result[project] ?? SearchResult(project: project, tasks: [], tags: [], findReasons: [])
                    sr.tasks.insert(task)
                    sr.findReasons.insert(.task(task.id))
                    result[project] = sr
                }
                for tag in task.tags {
                    if tag.localizedLowercase.contains(lowercaseSearchTerm) {
                        var sr = result[project] ?? SearchResult(project: project, tasks: [], tags: [], findReasons: [])
                        sr.tasks.insert(task)
                        sr.tags.insert(tag)
                        sr.findReasons.insert(.tag(tag))
                        result[project] = sr
                    }
                }
            }
        }
        
        return Array(result.values)
    }

    private var allTasks: [Task] {
        projects.flatMap { $0.tasks }
    }
    
    var dayInMonth: [Date] {(1...daysInMonth(date: currentMonth)).compactMap {
        Date.from(
            year: Calendar.current.dateComponents([.year], from: currentMonth).year!,
            month: Calendar.current.dateComponents([.month], from: currentMonth).month!,
            day: $0
        )}}
    
    var taskInMonth: [(Date, [Task])] {dayInMonth.compactMap { ($0, tasksInDay(date: $0, allTasks: allTasks))}.filter { !$0.1.isEmpty}}
    
    var body: some View {
        VStack(){
            
            SearchAndFilterView(isSearching: $isSearching, searchTerm: $searchTerm, isShowingPopover: $isShowingPopover)
            
            Group {
                if searchTerm.isEmpty {
                    ScrollView{
                        VStack{
                            ForEach(taskInMonth, id: \.0.self) { date, tasks in
                                ListDayView(date: date, tasks: tasks)
                            }
                        }
                    }
                } else if !searchResults.isEmpty {
                    List(searchResults) { result in
                        NavigationLink {
                            ProjectContentView(exercise: result.project)
                        } label: {
                            ProjectSearchResultView(result: result)
                        }
                    }
                    .listStyle(InsetListStyle())
                    .background(Color.white)
                }
                else {
                    Text("Nothing match !!".localized)
                }
            }
        }
        
    }
}

struct ListDayView: View {
    var date: Date
    var tasks: [Task]
    
    @Query var stopwatchData: [StopwatchData]
    
    var body: some View {
        VStack {
            let dateFormatter = { () -> DateFormatter in
                let df = DateFormatter()
                df.dateStyle = .medium
                return df
            }()
            
            HStack{
                Text("\(dateFormatter.string(from: date))")
                    .font(.system(size: 15))
                    .font(.headline)
                Spacer()
            }
            
            ForEach(tasks, id: \.self) { task in
                let stopwatchData = stopwatchData.filter { $0.taskId == task.id && Calendar.current.isDate($0.completionDate, inSameDayAs: date) }.first
                NavigationLink(destination: Stopwatch(taskId: task.id, date: date)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.name)
                                .font(.headline)
                        }
                        Spacer()
                        if let stopwatchData = stopwatchData {
                            Text(String(format: "Time: %@".localized, stopwatchData.totalInterval.formattedTime()))
                                .padding([.horizontal])
                        }
                        Image(systemName: stopwatchData != nil ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(stopwatchData != nil ? .green : .gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
    }
}
