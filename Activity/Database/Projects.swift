//
//  Exercise.swift
//  Activity
//
//  Created by Sandro  on 20.01.24.
//

import Foundation
import SwiftData

@Model
class Project {
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
    var id: UUID
    var name: String
    var checked: Bool
    var tags: [String]
    
    init(id: UUID = UUID(), name: String, checked: Bool = false, tags: [String] = []) {
        self.name = name
        self.checked = checked
        self.tags = tags
        self.id = id
    }
}
