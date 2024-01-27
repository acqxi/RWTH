//
//  TaskDetailView.swift
//  GymTime
//
//  Created by JieTing on 2024/1/15.
//

import SwiftUI
import SwiftData

struct ExerciseItem {
    let id = UUID()
    var name: String
    var repetitions: Int
    var isCompleted: Bool
}

struct TaskDetailView: View {
    var date: Date // date
    var exerciseItems: [Task] // items
    @Query(FetchDescriptor<StopwatchData>()) var stopwatchData: [StopwatchData]
    
    @Environment(\.modelContext) var context
    
    @State var showRestartStopwatchConfirmation = false
    @State var navigatingToStopwatch = false
    @State var continuingStopwatchDatum: StopwatchData?
    
    init(date: Date, exerciseItems: [Task]) {
        self.date = date
        self.exerciseItems = exerciseItems
        let taskIds = exerciseItems.map { $0.id }
        let viewDateComponents = Calendar.current.dateComponents(
            [.day, .month, .year],
            from: date
        )
        let minViewDate = Calendar.current.date(from: viewDateComponents)!
        let maxViewDate = Calendar.current.date(byAdding: .day, value: 1, to: minViewDate)!
        self._stopwatchData = Query(filter: #Predicate { stopwatchDatum in
            return minViewDate <= stopwatchDatum.completionDate && stopwatchDatum.completionDate < maxViewDate && taskIds.contains(stopwatchDatum.taskId)
        })
    }

    var body: some View {
        let dateFormatter = { () -> DateFormatter in
            let df = DateFormatter()
            df.dateStyle = .medium
            return df
        }()
        
        VStack(alignment: .leading, spacing: 10) {
            ForEach(exerciseItems.indices, id: \.self) { index in
                exerciseItemView(exerciseItems[index])
            }
            
            if exerciseItems.isEmpty {
                Spacer()
                
                Text("No tasks for this day")
                    .font(.title)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .navigationBarTitle(dateFormatter.string(from: date), displayMode: .inline)
        .padding()
    }

    private func exerciseItemView(_ item: Task) -> some View {
        let stopwatchDatum = stopwatchData.filter { $0.taskId == item.id }.first
        
        // TODO: "Do you want to do more work or delete and try again?"
        let label = HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
//                    Text("times: \(item.repetitions)")
//                        .font(.subheadline)
            }
            Spacer()
            Image(systemName: stopwatchDatum != nil ? "checkmark.circle.fill" : "circle")
                .foregroundColor(stopwatchDatum != nil ? .green : .gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        
        if stopwatchDatum == nil {
            return AnyView(
                NavigationLink(destination: Stopwatch(taskId: item.id, date: date)) {
                    label
                }
            )
        }
        else {
            return AnyView(
                Button {
                    showRestartStopwatchConfirmation = true
                } label: {
                    label
                        .confirmationDialog(
                            "Do you want to restart or continue the tracking?",
                            isPresented: $showRestartStopwatchConfirmation,
                            titleVisibility: .visible) {
                                Button(role: .destructive) {
                                    discardStopwatchData(for: item)
                                    navigateToStopwatch()
                                } label: {
                                    Text("Discard data and restart")
                                }
                                Button {
                                    navigateToStopwatch(continuingWith: stopwatchDatum)
                                } label: {
                                    Text("Continue tracking")
                                }
                            }
                }.navigationDestination(isPresented: $navigatingToStopwatch) {
                    Stopwatch(taskId: item.id, date: date, updating: continuingStopwatchDatum)
                }
            )
        }
    }
    
    private func discardStopwatchData(for task: Task) {
        let stopwatchDataForTask = stopwatchData.filter { $0.taskId == task.id }
        for datum in stopwatchDataForTask {
            context.delete(datum)
        }
    }
    private func navigateToStopwatch(continuingWith stopwatchData: StopwatchData? = nil) {
        continuingStopwatchDatum = stopwatchData
        navigatingToStopwatch = true
    }
}


#Preview {
    TaskDetailView(date: Date(), exerciseItems: [])
}
