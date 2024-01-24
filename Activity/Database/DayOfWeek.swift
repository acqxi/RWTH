//
//  DayOfWeek.swift
//  Activity
//
//  Created by TimurSmoev on 1/24/24.
//

import Foundation

enum DayOfWeek: Int, Codable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
    static let all: [DayOfWeek] = [
        .monday,
        .tuesday,
        .wednesday,
        .thursday,
        .friday,
        .saturday,
        .sunday,
    ]
}

extension DayOfWeek: Identifiable {
    var id: Int { self.rawValue }
}

extension DayOfWeek {
    var string : String {
        switch (self) {
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        case .sunday:
            return "Sunday"
        }
    }
    var shortString : String {
        let longString = self.string
        // Take only the first 3 letters from self.string
        // For example: Monday -> Mon; Tuesday -> Tue
        return String(longString[longString.startIndex..<longString.index(longString.startIndex, offsetBy: 3)])
    }
}
