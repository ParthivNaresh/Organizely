//
//  ProjectTaskView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/21/24.
//

import SwiftUI


enum SortType {
    case priorityAscending, priorityDescending
    case titleAscending, titleDescending
    case dueDateAscending, dueDateDescending
}

struct ProjectTasksListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentSortType: SortType = .priorityDescending
    @State private var isDueDateAscending: Bool = true
    @State private var isPriorityAscending: Bool = true
    @State private var isTitleAscending: Bool = true
    
    private var overdueTasksRequest: FetchRequest<ProjectTask>
    private var incompleteTasksRequest: FetchRequest<ProjectTask>
    private var completeTasksRequest: FetchRequest<ProjectTask>

    private var overdueTasks: FetchedResults<ProjectTask> { overdueTasksRequest.wrappedValue }
    private var incompleteTasks: FetchedResults<ProjectTask> { incompleteTasksRequest.wrappedValue }
    private var completeTasks: FetchedResults<ProjectTask> { completeTasksRequest.wrappedValue }
    
    var project: Project

    init(project: Project) {
        self.project = project
        self.overdueTasksRequest = FetchRequest<ProjectTask>(
            entity: ProjectTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
            predicate: NSPredicate(format: "isCompleted == false AND dateDue < %@ AND project == %@", Date() as NSDate, project)
        )
        self.incompleteTasksRequest = FetchRequest<ProjectTask>(
            entity: ProjectTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
            predicate: NSPredicate(format: "isCompleted == false AND dateDue >= %@ AND project == %@", Date() as NSDate, project)
        )
        self.completeTasksRequest = FetchRequest<ProjectTask>(
            entity: ProjectTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
            predicate: NSPredicate(format: "isCompleted == true AND project == %@", project)
        )
    }
    
    var sortedOverdueTasks: [ProjectTask] {
        overdueTasks.sorted {
            switch currentSortType {
            case .priorityAscending:
                return $0.priority < $1.priority
            case .priorityDescending:
                return $0.priority > $1.priority
            case .titleAscending:
                return ($0.title ?? "") < ($1.title ?? "")
            case .titleDescending:
                return ($0.title ?? "") > ($1.title ?? "")
            case .dueDateAscending:
                return ($0.dateDue ?? Date()) < ($1.dateDue ?? Date())
            case .dueDateDescending:
                return ($0.dateDue ?? Date()) > ($1.dateDue ?? Date())
            }
        }
    }
    
    var sortedIncompletedTasks: [ProjectTask] {
        incompleteTasks.sorted {
            switch currentSortType {
            case .priorityAscending:
                return $0.priority < $1.priority
            case .priorityDescending:
                return $0.priority > $1.priority
            case .titleAscending:
                return ($0.title ?? "") < ($1.title ?? "")
            case .titleDescending:
                return ($0.title ?? "") > ($1.title ?? "")
            case .dueDateAscending:
                return ($0.dateDue ?? Date()) < ($1.dateDue ?? Date())
            case .dueDateDescending:
                return ($0.dateDue ?? Date()) > ($1.dateDue ?? Date())
            }
        }
    }

    var sortedCompletedTasks: [ProjectTask] {
        completeTasks.sorted {
            switch currentSortType {
            case .priorityAscending:
                return $0.priority < $1.priority
            case .priorityDescending:
                return $0.priority > $1.priority
            case .titleAscending:
                return ($0.title ?? "") < ($1.title ?? "")
            case .titleDescending:
                return ($0.title ?? "") > ($1.title ?? "")
            case .dueDateAscending:
                return ($0.dateDue ?? Date()) < ($1.dateDue ?? Date())
            case .dueDateDescending:
                return ($0.dateDue ?? Date()) > ($1.dateDue ?? Date())
            }
        }
    }
    
    func togglePrioritySort() {
        isPriorityAscending.toggle()
        currentSortType = currentSortType == .priorityAscending ? .priorityDescending : .priorityAscending
    }

    func toggleTitleSort() {
        isTitleAscending.toggle()
        currentSortType = currentSortType == .titleAscending ? .titleDescending : .titleAscending
    }

    func toggleDueDateSort() {
        isDueDateAscending.toggle()
        currentSortType = currentSortType == .dueDateAscending ? .dueDateDescending : .dueDateAscending
    }

    var body: some View {
        HStack {
            SortButton(
                title: "Title",
                isAscending: $isTitleAscending,
                action: toggleTitleSort
            )
            SortButton(
                title: "Priority",
                isAscending: $isPriorityAscending,
                action: togglePrioritySort
            )
            SortButton(
                title: "Due Date",
                isAscending: $isDueDateAscending,
                action: toggleDueDateSort
            )
        }
        
        List {
            if !sortedOverdueTasks.isEmpty {
                Section(header: Text("Overdue")) {
                    ForEach(sortedOverdueTasks, id: \.self) { task in
                        TaskRowView(task: task)
                    }
                }
            }
            
            if !sortedIncompletedTasks.isEmpty {
                Section(header: Text("To Do")) {
                    ForEach(sortedIncompletedTasks, id: \.self) { task in
                        TaskRowView(task: task)
                    }
                }
            }

            if !sortedCompletedTasks.isEmpty {
                Section(header: Text("Completed")) {
                    ForEach(sortedCompletedTasks, id: \.self) { task in
                        TaskRowView(task: task)
                    }
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
