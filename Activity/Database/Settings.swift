//
//  Settings.swift
//  Activity
//
//  Created by Sandro  on 22.01.24.
//

import SwiftUI
import SwiftData

@Model
class Settings {
    var firstName: String?
    var lastName: String?
    var email: String?
    var birthday: Date?
    var accentColor: AccentColor
    var availableTags: [Tag]
    var notificationTime: HourAndMinute?
    
    init() {
        self.accentColor = .red
        self.availableTags = []
    }
}

@Model
class Tag {
    var name: String
    init(name: String){
        self.name = name
    }
}

struct HourAndMinute: Codable {
    var hour: Int
    var minute: Int
}

enum AccentColor: Codable {
    case red
    case green
    case blue
}

extension AccentColor {
    var string: String {
        switch self {
        case .red:
            return "Red"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        }
    }
    
    var swiftuiAccentColor: Color {
        switch self {
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
        }
    }
}
