//
//  ProjectTaskView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/21/24.
//

import SwiftUI

struct ProjectTasksListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isPriorityAscending: Bool = true
    @State private var isTitleAscending: Bool = true
    var project: Project
    
    private var incompleteTasksRequest: FetchRequest<ProjectTask>
    private var completeTasksRequest: FetchRequest<ProjectTask>

    var incompleteTasks: FetchedResults<ProjectTask> { incompleteTasksRequest.wrappedValue }
    var completeTasks: FetchedResults<ProjectTask> { completeTasksRequest.wrappedValue }

    init(project: Project) {
        self.project = project
        self.incompleteTasksRequest = FetchRequest<ProjectTask>(
            entity: ProjectTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
            predicate: NSPredicate(format: "isCompleted == NO AND project == %@", project)
        )
        self.completeTasksRequest = FetchRequest<ProjectTask>(
            entity: ProjectTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
            predicate: NSPredicate(format: "isCompleted == YES AND project == %@", project)
        )
    }
    
    var sortedCompletedTasks: [ProjectTask] {
        completeTasks.sorted {
            if $0.priority == $1.priority {
                return isTitleAscending ? ($0.title ?? "") < ($1.title ?? "") : ($0.title ?? "") > ($1.title ?? "")
            }
            return isPriorityAscending ? $0.priority < $1.priority : $0.priority > $1.priority
        }
    }

    var sortedIncompletedTasks: [ProjectTask] {
        incompleteTasks.sorted {
            if $0.priority == $1.priority {
                return isTitleAscending ? ($0.title ?? "") < ($1.title ?? "") : ($0.title ?? "") > ($1.title ?? "")
            }
            return isPriorityAscending ? $0.priority < $1.priority : $0.priority > $1.priority
        }
    }
    
    private func togglePrioritySort() {
        isPriorityAscending.toggle()
    }

    private func toggleTitleSort() {
        isTitleAscending.toggle()
    }

    var body: some View {
        HStack {
            Spacer()
            SortButton(
                title: "Priority",
                isAscending: $isPriorityAscending,
                action: togglePrioritySort
            )
            SortButton(
                title: "Title",
                isAscending: $isTitleAscending,
                action: toggleTitleSort
            )
        }
        
        List {
            Section(header: Text("To Do")) {
                ForEach(sortedIncompletedTasks, id: \.self) { task in
                    TaskRowView(task: task)
                }
            }

            Section(header: Text("Completed")) {
                ForEach(sortedCompletedTasks, id: \.self) { task in
                    TaskRowView(task: task)
                }
            }
        }
        .padding(.top, 0)
        .listStyle(PlainListStyle())
    }

    private func addProjectTask() {
        withAnimation {
            let newProjectTask = ProjectTask(context: viewContext)
            newProjectTask.dateCreated = Date()
            newProjectTask.dateDue = Date()
            newProjectTask.title = "New Task"
            newProjectTask.isCompleted = false
            newProjectTask.priority = 1
            newProjectTask.project = self.project

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
