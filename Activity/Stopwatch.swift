//
//  Stopwatch.swift
//  Activity
//
//  Created by Sandro  on 15.01.24.
//

import SwiftUI

struct Stopwatch: View {
    @StateObject private var viewModel = StopwatchViewModel()
    @Environment(\.colorScheme) var colorScheme

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
                    if (viewModel.elapsedPeriods < 1 || viewModel.elapsedTime.truncatingRemainder(dividingBy: 1) > 0.3) {
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
                            Text("Stop")
                                .padding()
                                .background(Color.red)
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
                        Button(action: viewModel.reset) {
                            Text("Reset")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}

class StopwatchViewModel: ObservableObject {
    @Published var timeElapsed: String = "00:00:00"
    @Published var isRunning: Bool = false
    @Published var hasStarted: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var period: TimeInterval = 60
    var elapsedPeriods: Double {
        get {
            return elapsedTime / period
        }
    }
    private var timer: Timer?
    private var lastUpdate: Date?

    func start() {
        isRunning = true
        hasStarted = true
        lastUpdate = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self, let lastUpdate = self.lastUpdate else { return }
            let currentTime = Date()
            let sinceLastUpdate = currentTime.timeIntervalSince(lastUpdate)
            elapsedTime += sinceLastUpdate
            self.lastUpdate = currentTime
            self.updateTimeElapsed(elapsedTime)
        }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
    }

    func reset() {
        stop()
        hasStarted = false
        elapsedTime = 0
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
    Stopwatch()
}

