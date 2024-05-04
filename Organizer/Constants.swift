//
//  Constants.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/21/24.
//

import Foundation
import SwiftUI


struct Constants {
    struct Titles {
        static let appName = "Organizely"
        static let todayTitle = "Today's Tasks"
        static let projectsTitle = "Projects"
        static let tasksTitle = "Tasks"
    }

    struct Projects {
        static let newProjectTitle = "New Project"
        static let newProjectHint = "Project Name"
        static let saveNewProject = "Save"
        static let cancelNewProject = "Cancel"
    }

    struct Tasks {
        static let newTaskTitle = "New Task"
        static let newTaskHint = "Task Name"
        static let saveNewTask = "Save"
        static let cancelNewTask = "Cancel"
    }
    
    static let priorities = [
        Priority(name: "Critical", color: .red, level: 5),
        Priority(name: "High", color: .yellow, level: 4),
        Priority(name: "Medium", color: .orange, level: 3),
        Priority(name: "Low", color: .green, level: 2),
        Priority(name: "Trivial", color: .blue, level: 1)
    ]
    
    static let labels = [
        TaskLabel(name: "School", color: .red),
        TaskLabel(name: "Work", color: .yellow),
        TaskLabel(name: "Home", color: .orange),
        TaskLabel(name: "Kids", color: .green),
        TaskLabel(name: "Pets", color: .blue)
    ]
}

struct Priority: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var color: Color
    var level: Int
}

struct TaskLabel: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var color: Color
}
