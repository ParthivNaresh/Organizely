//
//  TodayView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/21/24.
//

import SwiftUI

struct TodayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ProjectTask.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
        predicate: NSPredicate(format: "isCompleted == NO AND dateDue >= %@ AND dateDue < %@", Date().midnight as NSDate, Date().tomorrow as NSDate)
    ) var projectTasks: FetchedResults<ProjectTask>
    
    @State private var sortOption: SortOption = .priorityDescending
    
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
        VStack {
            Text(Constants.Titles.todayTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)

            Picker("Sort by:", selection: $sortOption) {
                ForEach(SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color(UIColor.systemGroupedBackground))

            List(sortedTasks, id: \.self) { task in
                TaskRowView(task: task)
            }
            .listStyle(PlainListStyle())
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var sortingPicker: some View {
        Picker("Sort", selection: $sortOption) {
            ForEach(SortOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

extension Date {
    var midnight: Date {
        Calendar.current.startOfDay(for: self)
    }

    var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self.midnight)!
    }
}

