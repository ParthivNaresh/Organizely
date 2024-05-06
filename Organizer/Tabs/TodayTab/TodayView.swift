//
//  TodayView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/21/24.
//

import SwiftUI


struct TodayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isPriorityAscending: Bool = true
    @State private var isTitleAscending: Bool = true
    
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
        VStack {
            Text(Constants.Titles.todayTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)

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
        .navigationBarTitleDisplayMode(.inline)
    }
}
