//
//  controlPanelView.swift
//  iTrackWorkout
//
//  Created by JieTing on 2024/1/29.
//

import SwiftUI
import SwiftData

// MARK: - Control Panel Rectangle Definition

/// Represents the rectangle of a control panel button with an associated view index.
struct controlPanelRect: Equatable {
    let viewIdx: Int
    let rect: CGRect
}

/// PreferenceKey to collect control panel rectangles.
struct controlPanelRectKey: PreferenceKey {
    typealias Value = [controlPanelRect]
    static var defaultValue: [controlPanelRect] = []
    static func reduce(value: inout [controlPanelRect], nextValue: () -> [controlPanelRect]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Control Panel Button View

/// View for a button in the control panel.
struct ctrlPanelBtnView: View {
    @Binding var activeBtn: Int
    let idx: Int
    let viewStyle = ["Cal.", "List."]
    
    var body: some View {
        Text("\(viewStyle[idx])")
            .padding(3)
            .background(ctrlPanelBtnSetrView(idx: idx))
    }
}

/// Sets the geometry for a control panel button.
struct ctrlPanelBtnSetrView: View {
    let idx: Int
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: controlPanelRectKey.self,
                            value: [controlPanelRect(viewIdx: self.idx, rect: geometry.frame(in: .named("controlPanelZStack")))])
        }
    }
}

// MARK: - Control Panel View

/// View for the control panel, including navigation and style toggle.
struct controlPanelView: View {
    
    @Binding var styleIdx: Int
    @Binding var currentMonth: Date
    
    @State private var rects: [CGRect] = Array<CGRect>(repeating: CGRect(), count: 12)
        
    var body: some View {
        // Controls for changing the current month.
        HStack {
            Button(action: { self.changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            
            Text("\(currentMonth, formatter: DateFormatter.monthAndYear)")
                .font(.headline)
            Spacer()
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.8))
                    .frame(width: rects[styleIdx].size.width, height: rects[styleIdx].size.height)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 5.0).foregroundColor(.accentColor)
                    )
                    .offset(x: rects[styleIdx].minX, y: rects[styleIdx].minY)
                    .animation(.easeInOut(duration: 0.35), value: styleIdx)
                
                HStack{
                    ForEach(0...1, id: \.self) { col in
                        ctrlPanelBtnView(activeBtn: $styleIdx, idx: col)
                    }
                }
                
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
            .coordinateSpace(name: "controlPanelZStack")
            .onTapGesture { styleIdx = (styleIdx + 1) % 2 }
            
            Spacer()
            Button(action: { self.changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
        .onPreferenceChange(controlPanelRectKey.self) { preferences in
            for p in preferences {
                self.rects[p.viewIdx] = p.rect
            }
        }
    }
    
    /// Changes the current month displayed.
    func changeMonth(by amount: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: amount, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

