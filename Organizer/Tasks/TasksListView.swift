//
//  TasksListView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 5/3/24.
//

import SwiftUI


struct TasksListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var project: Project?
    
    @FetchRequest private var projectTasks: FetchedResults<ProjectTask>

    init(project: Project? = nil) {
        self.project = project
        let predicate: NSPredicate
        if let project = project {
            predicate = NSPredicate(format: "isCompleted == false AND project == %@", project)
        } else {
            predicate = NSPredicate(format: "isCompleted == false")
        }
        _projectTasks = FetchRequest(
            entity: ProjectTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
            predicate: predicate
        )
    }

    var body: some View {
        List {
            ForEach(projectTasks, id: \.self) { task in
                TaskRowView(task: task)
            }
            .onDelete(perform: deleteProjectTask)
        }
    }

    private func deleteProjectTask(offsets: IndexSet) {
        withAnimation {
            offsets.map { projectTasks[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
