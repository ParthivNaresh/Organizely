//
//  TodayView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/21/24.
//

import SwiftUI

struct TodayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentSortType: SortType = .priorityDescending
    @State private var isDueDateAscending: Bool = true
    @State private var isPriorityAscending: Bool = true
    @State private var isTitleAscending: Bool = true

    @FetchRequest(
        entity: ProjectTask.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
        predicate: NSPredicate(format: "isCompleted == NO AND dateDue < %@", Date().midnight as NSDate)
    ) var overdueTasks: FetchedResults<ProjectTask>

    @FetchRequest(
        entity: ProjectTask.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
        predicate: NSPredicate(format: "isCompleted == NO AND dateDue >= %@ AND dateDue < %@", Date().midnight as NSDate, Date().tomorrow as NSDate)
    ) var incompleteTasks: FetchedResults<ProjectTask>

    @FetchRequest(
        entity: ProjectTask.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
        predicate: NSPredicate(format: "isCompleted == YES AND dateDue >= %@ AND dateDue < %@", Date().midnight as NSDate, Date().tomorrow as NSDate)
    ) var completeTasks: FetchedResults<ProjectTask>

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
        VStack {
            Text(Constants.Titles.todayTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)

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
                Section(header: Text("Overdue")) {
                    ForEach(sortedOverdueTasks, id: \.self) { task in
                        TaskRowView(task: task)
                    }
                }
                
                Section(header: Text("Due Today")) {
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
        .navigationBarTitleDisplayMode(.inline)
    }
}
