//
//  Stopwatch.swift
//  Activity
//
//  Created by Sandro  on 15.01.24.
//  Refactored and commented on by Yu-Ting on 27.01.24.
//

import SwiftUI
import SwiftData

struct Stopwatch: View {
    var date: Date // The date associated with the stopwatch.
    @State var taskId: UUID // Identifier for the task related to this stopwatch.
    @State var modelInserted = false // Flag to track if the model has been inserted.
    @StateObject private var viewModel = StopwatchViewModel() // ViewModel for the stopwatch.
    @Environment(\.colorScheme) var colorScheme // Current color scheme of the device.
    @Environment(\.modelContext) var context// The model context for data handling.
    
    // Initializing the stopwatch with a task ID and date.
    init(taskId: UUID, date: Date) {
        self._taskId = State(initialValue: taskId)
        self.date = date
    }
    
    var body: some View {
            ZStack {
                background
                VStack {
                    stopwatchCircle
                    controlButtons
                }
            }
        }

        private var background: some View {
            Color.black.opacity(0.06).edgesIgnoringSafeArea(.all)
        }
        
        private var stopwatchCircle: some View {
            ZStack {
                Circle()
                    .stroke(colorScheme == .light ? Color.black.opacity(0.09) : Color.white.opacity(0.09), lineWidth: 14)
                    .frame(width: 280, height: 280)
                if viewModel.shouldDisplayProgress {
                    Circle()
                        .trim(from: 0, to: min(viewModel.elapsedPeriods, 1.0))
                        .stroke(AngularGradient(colors: [.yellow, .orange, .pink, .red], center: .center), style: StrokeStyle(lineWidth: 20, lineCap: .butt, lineJoin: .miter))
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                }
                Text(viewModel.timeElapsed)
                    .font(.largeTitle)
            }
            .padding()
        }
    
        private var controlButtons: some View {
            HStack {
                Button(action: viewModel.isRunning ? viewModel.stop : viewModel.start) {
                    Text(viewModel.isRunning ? "Pause" : "Start")
                        .styledButton(backgroundColor: viewModel.isRunning ? .orange : .green)
                }
                
                if viewModel.hasStarted {
                    finishButton
                }
            }
            .padding()
        }
        
        private var finishButton: some View {
            Button(action: {
                viewModel.stop()
                saveStopwatchData()
            }) {
                Text("Finish").styledButton(backgroundColor: .red)
            }
        }
        
        private func saveStopwatchData() {
            let stopwatchData = StopwatchData(
                completionDate: date,
                taskId: taskId,
                times: viewModel.stopwatchData.map(Time.init)
            )
            context.insert(stopwatchData)
        }
    }

    // Extending View for commonly used button styles
    extension View {
        func styledButton(backgroundColor: Color) -> some View {
            self.padding()
                .background(backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

class StopwatchViewModel: ObservableObject {
    @Published var timeElapsed: String = "00:00:00"
    @Published var isRunning: Bool = false
    @Published var hasStarted: Bool = false
    @Published var stopwatchData: [(Date, Date)] = []
    private var previousElapsedTime: TimeInterval = 0
    private var currentElapsedTime: TimeInterval = 0
    private var period: TimeInterval = 60
    private var timer: Timer?
    private var startTime: Date?
    
    var elapsedPeriods: Double { (previousElapsedTime + currentElapsedTime) / period }
    var shouldDisplayProgress: Bool { elapsedPeriods < 1 || (previousElapsedTime + currentElapsedTime).truncatingRemainder(dividingBy: 1) > 0.3 }

    func start() {
        isRunning = true
        hasStarted = true
        startTime = Date()
        startTimer()
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        if let startTime = startTime {
            updateStopwatchData(start: startTime, end: Date())
            self.startTime = nil
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateTimeElapsed()
        }
    }

    private func updateStopwatchData(start: Date, end: Date) {
        let sinceStart = end.timeIntervalSince(start)
        currentElapsedTime = 0
        previousElapsedTime += sinceStart
        stopwatchData.append((start, end))
    }

    private func updateTimeElapsed() {
        guard let startTime = startTime else { return }
        let elapsedTime = Date().timeIntervalSince(startTime) + previousElapsedTime
        let seconds = Int(elapsedTime) % 60
        let minutes = Int(elapsedTime / 60) % 60
        let hours = Int(elapsedTime / 3600)
        timeElapsed = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    return Stopwatch(taskId: UUID(), date: Date())
}

