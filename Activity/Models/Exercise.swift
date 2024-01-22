//
//  Exercise.swift
//  Activity
//
//  Created by Sandro  on 20.01.24.
//

import Foundation
import SwiftData

@Model
class Exercise {
    var name: String
    var tasks: [Task]
    
    init(name: String) {
        self.name = name
        self.tasks = []
    }
    
    init(name: String, tasks: [Task]) {
        self.name = name
        self.tasks = tasks
    }
}

@Model
class Task: Identifiable {
    var id: String {
        get {
            return name
        }
    }
    
    var name: String
    var checked: Bool
    var tags: [String]
    
    init(name: String, tags: [String] = []) {
        self.name = name
        self.checked = false
        self.tags = tags
    }
    
    init(name: String, checked: Bool, tags: [String] = []) {
        self.name = name
        self.checked = checked
        self.tags = tags
    }
}
