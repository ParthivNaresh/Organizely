//
//  ProjectsView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/21/24.
//

import SwiftUI
import CoreData


struct ProjectRowView: View {
    @ObservedObject var project: Project
    @Environment(\.managedObjectContext) private var viewContext
    
    var completedTasksRequest: FetchRequest<ProjectTask>
    var completedTasks: FetchedResults<ProjectTask> { completedTasksRequest.wrappedValue }

    // Fetch not completed tasks for this project
    var notCompletedTasksRequest: FetchRequest<ProjectTask>
    var notCompletedTasks: FetchedResults<ProjectTask> { notCompletedTasksRequest.wrappedValue }
    
    init(project: Project) {
        self.project = project
        completedTasksRequest = FetchRequest<ProjectTask>(
            entity: ProjectTask.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "project == %@ AND isCompleted == true", project)
        )
        notCompletedTasksRequest = FetchRequest<ProjectTask>(
            entity: ProjectTask.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "project == %@ AND isCompleted == false", project)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(project.title ?? "Unnamed Project")
                .font(.headline)
                .foregroundColor(.primary)

            if let description = project.projectDescription {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                if let dateDue = project.dateDue {
                    Text("Due: \(dateDue, formatter: DateFormatter.projectFormatter)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("\(completedTasks.count) Completed")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("|")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(notCompletedTasks.count) Open")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func completedTaskCount(for project: Project) -> Int {
        taskCount(for: project, isCompleted: true)
    }

    private func notCompletedTaskCount(for project: Project) -> Int {
        taskCount(for: project, isCompleted: false)
    }

    private func taskCount(for project: Project, isCompleted: Bool) -> Int {
        let request: NSFetchRequest<ProjectTask> = ProjectTask.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "project == %@", project),
            NSPredicate(format: "isCompleted == %@", NSNumber(value: isCompleted))
        ])
        return (try? viewContext.count(for: request)) ?? 0
    }
}

extension DateFormatter {
    static let projectFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
