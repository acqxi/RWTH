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
    var accentColor: AccentColor
    var availableTags: [Tag]
    
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
