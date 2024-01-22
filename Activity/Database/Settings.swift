//
//  Settings.swift
//  Activity
//
//  Created by Sandro  on 22.01.24.
//

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
}
