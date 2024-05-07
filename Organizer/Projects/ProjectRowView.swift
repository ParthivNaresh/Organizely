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
    
    private var overdueTasksRequest: FetchRequest<ProjectTask>
    private var completedTasksRequest: FetchRequest<ProjectTask>
    private var incompleteTasksRequest: FetchRequest<ProjectTask>
    
    private var overdueTasks: FetchedResults<ProjectTask> { overdueTasksRequest.wrappedValue }
    private var completedTasks: FetchedResults<ProjectTask> { completedTasksRequest.wrappedValue }
    private var incompleteTasks: FetchedResults<ProjectTask> { incompleteTasksRequest.wrappedValue }
    
    init(project: Project) {
        self.project = project
        overdueTasksRequest = FetchRequest<ProjectTask>(
            entity: ProjectTask.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "isCompleted == false AND dateDue < %@ AND project == %@", Date() as NSDate, project)
        )
        completedTasksRequest = FetchRequest<ProjectTask>(
            entity: ProjectTask.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "isCompleted == true AND project == %@", project)
        )
        incompleteTasksRequest = FetchRequest<ProjectTask>(
            entity: ProjectTask.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "isCompleted == false AND dateDue >= %@ AND project == %@", Date() as NSDate, project)
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
            if let dateDue = project.dateDue {
                Text("Due: \(dateDue, formatter: DateFormatter.projectFormatter)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Text("\(overdueTasks.count) Overdue")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("|")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(incompleteTasks.count) Open")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("|")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(completedTasks.count) Completed")
                        .font(.caption)
                        .foregroundColor(.green)
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
