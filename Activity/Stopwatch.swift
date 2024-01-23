//
//  Stopwatch.swift
//  Activity
//
//  Created by Sandro  on 15.01.24.
//

import SwiftUI
import SwiftData

struct Stopwatch: View {
    @StateObject private var viewModel: StopwatchViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    
    init(taskId: UUID) {
        _viewModel = StateObject(wrappedValue: StopwatchViewModel(taskId: taskId))
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.06).edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(colorScheme == .light ? Color.black.opacity(0.09) : Color.white.opacity(0.09), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 280, height: 280)
                        .padding()
                    if (viewModel.elapsedPeriods < 1 || viewModel.totalElapsedTime.truncatingRemainder(dividingBy: 1) > 0.3) {
                        Circle()
                            .trim(from: 0, to: min(viewModel.elapsedPeriods, 1.0))
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                            .frame(width: 280, height: 280)
                            .rotationEffect(.degrees(-90))
                            .padding()
                    }
//                    ForEach(1..<Int(viewModel.elapsedPeriods + 1), id: \.self) { idx in
//                        Circle()
//                            .trim(from: 0, to: (viewModel.elapsedTime.truncatingRemainder(dividingBy: 60)) / 60.0)
//                            .stroke(Color.red, style: StrokeStyle(lineWidth: 14, lineCap: .round))
//                            .frame(width: 280, height: 280)
//                            .rotationEffect(.degrees(-90))
//                            .padding()
//                    }
                    Text(viewModel.timeElapsed)
                        .font(.largeTitle)
                        .padding()
                }

                HStack {
                    if viewModel.isRunning {
                        Button(action: viewModel.stop) {
                            Text("Pause")
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else {
                        Button(action: viewModel.start) {
                            Text("Start")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    if viewModel.hasStarted {
                        Button(action:{
                            viewModel.stop()
                            context.insert(viewModel.stopwatchData)
                        } ) {
                            Text("End")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
//                List{
//                    ForEach(times) { time in
//                        
//                            Text(time)
//                        }
//                        // TODO: Use .sheet()
//                    }

                    .padding()
                                    
                }
            }
        }
    
}

class StopwatchViewModel: ObservableObject {
    @Published var timeElapsed: String = "00:00:00"
    @Published var isRunning: Bool = false
    @Published var hasStarted: Bool = false
    @Published var previousElapsedTime: TimeInterval = 0
    @Published var currentElapsedTime: TimeInterval = 0
    @Published var period: TimeInterval = 60
    @Published var stopwatchData: StopwatchData
    var elapsedPeriods: Double {totalElapsedTime / period}
    var totalElapsedTime: TimeInterval {previousElapsedTime + currentElapsedTime}
    private var timer: Timer?
    private var startTime: Date?

    init (taskId: UUID){
        stopwatchData = StopwatchData(taskId: taskId, times: [])
    }
    
    func start() {
        isRunning = true
        hasStarted = true
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            let currentTime = Date()
            let sinceStart = currentTime.timeIntervalSince(startTime)
            currentElapsedTime = sinceStart
            self.updateTimeElapsed(previousElapsedTime + currentElapsedTime)
        }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        let currentTime = Date()
        if let startTime = startTime {
            let sinceStart = currentTime.timeIntervalSince(startTime)
            currentElapsedTime = 0
            previousElapsedTime += sinceStart
            stopwatchData.times.append(Time(start: startTime, end: currentTime))
        }
        
        
        
    }

    func reset() {
        stop()
        hasStarted = false
        currentElapsedTime = 0
        updateTimeElapsed(0)
    }

    private func updateTimeElapsed(_ elapsedTime: TimeInterval) {
        let seconds = Int(elapsedTime) % 60
        let minutes = Int(elapsedTime / 60) % 60
        let hours = Int(elapsedTime / 3600)
        timeElapsed = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}


#Preview {
    
    return Stopwatch(taskId: UUID())
    
}

