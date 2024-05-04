//
//  ProjectTaskView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/21/24.
//

import SwiftUI

struct ProjectTasksListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var sortOption: SortOption = .priorityDescending
    var project: Project
    
    @FetchRequest private var projectTasks: FetchedResults<ProjectTask>

    init(project: Project) {
        self.project = project
        _projectTasks = FetchRequest(
            entity: ProjectTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
            predicate: NSPredicate(format: "isCompleted == NO AND project == %@", project)
        )
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case priorityAscending = "Priority Ascending"
        case priorityDescending = "Priority Descending"
        
        var id: String { self.rawValue }
    }
    
    var sortedTasks: [ProjectTask] {
        projectTasks.sorted {
            switch sortOption {
            case .priorityAscending:
                return ($0.priority, $0.taskLabel ?? "") < ($1.priority, $1.taskLabel ?? "")
            case .priorityDescending:
                return ($0.priority, $0.taskLabel ?? "") > ($1.priority, $1.taskLabel ?? "")
            }
        }
    }

    var body: some View {
        Picker("Sort by:", selection: $sortOption) {
            ForEach(SortOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        
        List {
            ForEach(sortedTasks, id: \.self) { task in
                TaskRowView(task: task)
            }
            .onDelete(perform: deleteProjectTask)
        }
        .listStyle(PlainListStyle())
        .navigationTitle(project.title ?? "Project Tasks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addProjectTask) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
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
