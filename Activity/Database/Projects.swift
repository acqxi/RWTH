//
//  Exercise.swift
//  Activity
//
//  Created by Sandro  on 20.01.24.
//

import Foundation
import SwiftData

@Model
class Projects: Identifiable {
    let id = UUID()  // Unique identifier for Identifiable protocol
    var name: String
    var tasks: [Task]
    var startDate: Date  // Date type
    var priority: Int
    
    init(name: String, startDate: Date, priority: Int = 2) {
        self.name = name
        self.tasks = []
        self.startDate = startDate
        self.priority = priority
    }
    
    init(name: String, tasks: [Task], startDate: Date, priority: Int = 2) {
        self.name = name
        self.tasks = tasks
        self.startDate = startDate
        self.priority = priority
    }
}

@Model
class Task: Identifiable {
    let id = UUID()  // Unique identifier for Identifiable protocol
    
    var name: String
    var checked: Bool
    var tags: [String]
    var startDate: Date  // Date type
    var priority: Int
    
    init(name: String, tags: [String] = [], startDate: Date, priority: Int = 2) {
        self.name = name
        self.checked = false
        self.tags = tags
        self.startDate = startDate
        self.priority = priority
    }
    
    init(name: String, checked: Bool, tags: [String] = [], startDate: Date, priority: Int = 2) {
        self.name = name
        self.checked = checked
        self.tags = tags
        self.startDate = startDate
        self.priority = priority
    }
}
