//
//  NewTaskViews.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/25/24.
//

import SwiftUI
import MapKit
import Combine
import MijickCalendarView

struct NewTaskTitleAndDescriptionView: View {
    @Binding var taskName: String
    @Binding var taskDescription: String
    @FocusState var isInputActive: Bool
    @Binding var showError: Bool
    
    var body: some View{
        TextField("e.g. Take cat to the vet Friday at 3p.m.", text: $taskName)
            .onReceive(Just(taskName)) { newValue in
                showError = newValue.isEmpty
            }
            .focused($isInputActive)
            .padding(EdgeInsets(top: 8, leading: 15, bottom: 4, trailing: 15))
            .background(Color.white)
            .cornerRadius(1)
            .font(.system(size: 20, weight: .semibold))
        TextField("Task Description", text: $taskDescription)
            .padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 10))
            .background(Color.white)
            .cornerRadius(1)
    }
}

struct NewSubtaskTitleAndDescriptionView: View {
    @Binding var taskName: String
    @Binding var taskDescription: String
    @FocusState var isInputActive: Bool
    @Binding var showError: Bool
    
    var body: some View{
        VStack(spacing: 0) {
            TextField("e.g. Take cat to the vet Friday at 3p.m.", text: $taskName)
                .onReceive(Just(taskName)) { newValue in
                    showError = newValue.isEmpty
                }
                .focused($isInputActive)
                .padding(EdgeInsets(top: 8, leading: 15, bottom: 4, trailing: 0))
                .font(.system(size: 18, weight: .semibold))
            TextField("Task Description", text: $taskDescription)
                .padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 0))
                .font(.system(size: 16, weight: .light))
        }
        .background(Color.clear)
    }
}

struct TaskControlButtonsView: View {
    @Binding var showPriorityList: Bool
    @Binding var selectedPriority: Priority?
    @Binding var showDatePicker: Bool
    @Binding var dateDue: Date?
    @Binding var showLabelList: Bool
    @Binding var selectedLabel: TaskLabel?
    @Binding var showingLocationPicker: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                NewTaskTodayButtonView(
                    showDatePicker: $showDatePicker,
                    dateDue: $dateDue
                )
                NewTaskPriorityButtonView(
                    showPriorityList: $showPriorityList,
                    selectedPriority: $selectedPriority
                )
                NewTaskReminderButtonView()
                NewTaskLabelsButtonView(
                    showLabelList: $showLabelList,
                    selectedLabel: $selectedLabel
                )
                NewTaskLocationButtonView(showingLocationPicker: $showingLocationPicker)
            }
            .padding(.horizontal, 10)
        }
    }
}

struct NewTaskTodayButtonView: View {
    @Binding var showDatePicker: Bool
    @Binding var dateDue: Date?
    
    var body: some View{
        Button(action: {
            showDatePicker = true
        }) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                Text(dateDueString)
                    .font(.system(size: 12))
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 8)
        }
        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.5), lineWidth: 0.2)
        )
        .padding(2)
    }
    
    private var dateDueString: String {
        guard let dateDue = dateDue else {
            return "Today"
        }
        let calendar = Calendar.current
        let now = Date()
        if calendar.isDateInToday(dateDue) {
            return "Today"
        } else if calendar.isDateInTomorrow(dateDue) {
            return "Tomorrow"
        } else if calendar.isDate(dateDue, equalTo: now, toGranularity: .year) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d"
            return dateFormatter.string(from: dateDue)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: dateDue)
        }
    }
}

struct NewTaskPriorityButtonView: View {
    @Binding var showPriorityList: Bool
    @Binding var selectedPriority: Priority?
    
    var body: some View{
        Button(action: {
            withAnimation {
                showPriorityList.toggle()
            }
        }) {
            HStack {
                Image(systemName: "flag.fill")
                    .font(.system(size: 12))
                    .foregroundColor(selectedPriority?.color ?? .gray)
                Text(selectedPriority?.name ?? "Priority")
                    .font(.system(size: 12))
                    .fontWeight(.medium)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 8)
        }
        .foregroundColor(Color.black)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.5), lineWidth: 0.2)
        )
        .padding(2)
    }
}

struct PrioritySelectionOverlay: View {
    @Binding var showPriorityList: Bool
    @Binding var selectedPriority: Priority?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(Constants.priorities) { priority in
                Button(action: {
                    withAnimation {
                        selectedPriority = priority
                        showPriorityList = false
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "flag.fill")
                            .foregroundColor(priority.color)
                            .font(.system(size: 14))
                        Text(priority.name)
                            .fontWeight(.medium)
                            .font(.system(size: 14))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 15)
                    .frame(width: 120, alignment: .leading)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(priority.color.opacity(0.4), lineWidth: 0.75)
                    )
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
        .animation(.easeInOut, value: showPriorityList)
        .transition(.move(edge: .top))
        .frame(width: 200)
    }
}


struct NewTaskReminderButtonView: View {
    
    var body: some View{
        Button(action: {}) {
            HStack {
                Image(systemName: "alarm")
                    .font(.system(size: 12))
                Text("Reminder")
                    .font(.system(size: 12))
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 6)
        }
        .foregroundColor(Color.black)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.5), lineWidth: 0.2)
        )
        .padding(2)
    }
}

struct NewTaskLabelsButtonView: View {
    @Binding var showLabelList: Bool
    @Binding var selectedLabel: TaskLabel?
    
    var body: some View{
        Button(action: {
            withAnimation {
                showLabelList.toggle()
            }
        }) {
            HStack {
                Image(systemName: "tag")
                    .font(.system(size: 12))
                Text(selectedLabel?.name ?? "Labels")
                    .font(.system(size: 12))
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 8)
        }
        .foregroundColor(selectedLabel?.color ?? Color(red: 0.0, green: 0.0, blue: 0.7))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.5), lineWidth: 0.2)
        )
        .padding(2)
    }
}


struct LabelSelectionOverlay: View {
    @Binding var showLabelList: Bool
    @Binding var selectedLabel: TaskLabel?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(Constants.labels) { label in
                Button(action: {
                    withAnimation {
                        selectedLabel = label
                        showLabelList = false
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "tag.fill")
                            .foregroundColor(label.color)
                            .font(.system(size: 14))
                        Text(label.name)
                            .fontWeight(.medium)
                            .font(.system(size: 14))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 15)
                    .frame(width: 120, alignment: .leading)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(label.color.opacity(0.4), lineWidth: 0.75)
                    )
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
        .animation(.easeInOut, value: showLabelList)
        .transition(.move(edge: .top))
        .frame(width: 200)
    }
}


struct NewTaskLocationButtonView: View {
    @Binding var showingLocationPicker: Bool
    
    var body: some View{
        Button(action: {showingLocationPicker = true}) {
            HStack {
                Image(systemName: "location")
                    .font(.system(size: 12))
                Text("Location")
                    .font(.system(size: 12))
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 8)
        }
        .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.8))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.5), lineWidth: 0.2)
        )
        .padding(2)
    }
}

struct NewTaskAddSubTaskButtonView: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus")
                    .imageScale(.small)
                    .foregroundColor(.blue)
                Text("Add Subtask")
                    .fontWeight(.light)
                    .font(.system(size: 16))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
        }
        .padding(.horizontal, 10)
        .buttonStyle(PlainButtonStyle())
    }
}

struct SubtasksListView: View {
    var subtasks: [ProjectSubtask]
    
    init(subtasks: [ProjectSubtask]) {
        self.subtasks = subtasks
        print("Loaded \(subtasks.count) subtasks")
        if subtasks.count > 0 {
            print("First title: \(String(describing: subtasks[0].title))")
        }
    }


    var body: some View {
        VStack {
            List(subtasks, id: \.self) { subtask in
                HStack {
                    VStack(alignment: .leading) {
                        Text(subtask.title ?? "Untitled")
                            .font(.headline)
                        Text(subtask.subtaskDescription ?? "No description")
                            .font(.subheadline)
                    }
                }
            }
        }
        .background(Color.blue)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddSubtaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showError: Bool = false
    @State private var newSubtaskName: String = ""
    @State private var newSubtaskDescription: String = ""
    @Binding var showingAddSubTaskView: Bool
    @FocusState private var isInputActive: Bool
    var task: ProjectTask
    @FetchRequest private var projectSubtasks: FetchedResults<ProjectSubtask>
    
    init(task: ProjectTask, showingAddSubTaskView: Binding<Bool>) {
        self.task = task
        self._showingAddSubTaskView = showingAddSubTaskView
        _projectSubtasks = FetchRequest(
            entity: ProjectSubtask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ProjectSubtask.title, ascending: true)]
        )
    }
    
    var body: some View {
        HStack {
            NewSubtaskTitleAndDescriptionView(
                taskName: $newSubtaskName,
                taskDescription: $newSubtaskDescription,
                isInputActive: _isInputActive,
                showError: $showError
            )
            Button(action: saveSubtask) {
                if newSubtaskName.isEmpty {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .imageScale(.large)
                }
                else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .imageScale(.large)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 10))
            .disabled(newSubtaskName.isEmpty)
        }
    }
    
    private func saveSubtask() {
        let newSubtask = ProjectSubtask(context: viewContext)
        newSubtask.title = newSubtaskName
        newSubtask.subtaskDescription = newSubtaskDescription
        newSubtask.dateCreated = Date()
        newSubtask.dateUpdated = Date()
        newSubtask.isCompleted = false
        newSubtask.task = task
        
        do {
            try viewContext.save()
            showingAddSubTaskView = false
        } catch {
            showError = true
            print("Failed to save subtask: \(error)")
        }
    }
}


struct NewTaskAddTaskButtonView: View {
    var action: () -> Void
    var isEnabled: Bool

    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(isEnabled ? .blue : .gray)
            }
            .disabled(!isEnabled)
            .padding(.trailing, 20)
        }
    }
}


struct PrioritySelectionView: View {
    @Binding var showPriorityList: Bool
    @Binding var selectedPriority: Priority?

    var body: some View {
        Group {
            if showPriorityList {
                PrioritySelectionOverlay(showPriorityList: $showPriorityList, selectedPriority: $selectedPriority)
                    .alignmentGuide(.top) { _ in 50 }
            }
        }
    }
}

struct LabelSelectionOverlayView: View {
    @Binding var showLabelList: Bool
    @Binding var selectedLabel: TaskLabel?

    var body: some View {
        Group {
            if showLabelList {
                LabelSelectionOverlay(showLabelList: $showLabelList, selectedLabel: $selectedLabel)
                    .alignmentGuide(.top) { _ in 50 }
            }
        }
    }
}

struct DatePickerSheetContentView: View {
    @Binding var dateDue: Date?
    @Binding var showingDatePicker: Bool
    @Binding var selectedRange: MDateRange?

    var body: some View {
        DatePickerSheetView(dateDue: $dateDue, showingDatePicker: $showingDatePicker, selectedRange: $selectedRange)
    }
}

struct LocationPickerSheetContentView: View {
    @Binding var showingLocationPicker: Bool
    @Binding var selectedLocation: CLLocationCoordinate2D?

    var body: some View {
        LocationPickerSheetView(showingLocationPicker: $showingLocationPicker, selectedLocation: $selectedLocation)
    }
}


