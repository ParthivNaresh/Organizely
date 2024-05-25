//
//  AddTaskSheet.swift
//  Organizer
//
//  Created by Parthiv Naresh on 5/3/24.
//

import SwiftUI
import MapKit
import MijickCalendarView


struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isVisible: Bool
    @FocusState private var isInputActive: Bool
    @Binding var selectedProject: Project?
    @State private var task: ProjectTask?
    var isSubtask: Bool

    @State private var taskName: String = ""
    @State private var taskDescription: String = ""
    @State private var dateDue: Date? = Date()
    @State private var categories: [String] = []
    @State private var selectedCategory: String?
    @State private var selectedPriority: Priority? = nil
    @State private var showPriorityList = false
    @State private var selectedLabel: TaskLabel? = nil
    @State private var showLabelList = false
    @State private var attemptToSubmit: Bool = false
    @State private var showError: Bool = false
    @State private var showingDatePicker = false
    @State private var showingLocationPicker = false
    @State private var selectedLocation: CLLocationCoordinate2D? = nil
    @State private var selectedRange: MDateRange? = .init()
    @State private var settingsDetent: PresentationDetent = .fraction(0.2)
    @State private var taskSubtasks: Set<ProjectSubtask> = []
    @State var detents: Set<PresentationDetent> = [.fraction(0.2)]
    @State private var showingAddSubTaskView: Bool = false
    @State private var isShowingSubtaskDetails = false
    
    @FetchRequest var projectSubtasks: FetchedResults<ProjectSubtask>

    init(
        isVisible: Binding<Bool>,
        selectedProject: Binding<Project?> = .constant(nil),
        task: ProjectTask? = nil,
        isSubtask: Bool = false
    ) {
        self._isVisible = isVisible
        self._selectedProject = selectedProject
        self.task = task
        self.isSubtask = isSubtask
        
        if let task = task {
            self._projectSubtasks = FetchRequest<ProjectSubtask>(
                sortDescriptors: [NSSortDescriptor(keyPath: \ProjectSubtask.title, ascending: true)],
                predicate: NSPredicate(format: "task == %@", task)
            )
        } else {
            self._projectSubtasks = FetchRequest<ProjectSubtask>(
                sortDescriptors: [NSSortDescriptor(keyPath: \ProjectSubtask.title, ascending: true)]
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NewTaskTitleAndDescriptionView(
                taskName: $taskName,
                taskDescription: $taskDescription,
                isInputActive: _isInputActive,
                showError: $showError
            )
            Spacer()
            TaskControlButtonsView(
                showPriorityList: $showPriorityList,
                selectedPriority: $selectedPriority,
                showDatePicker: $showingDatePicker,
                dateDue: $dateDue,
                showLabelList: $showLabelList,
                selectedLabel: $selectedLabel,
                showingLocationPicker: $showingLocationPicker
            )
            Spacer()
            HStack {
                NewSubtaskAddSubtaskButtonView(
                    action: toggleAddSubTask
                )
                NewTaskSubmitTaskButtonView(
                    action: addTask,
                    isEnabled: !taskName.isEmpty
                )
            }

            if let taskUnwrapped = task {
                SubtasksListView(task: taskUnwrapped)
            }
        }
        .onAppear {
            loadInitialData()
        }
        .presentationDetents(
            detents,
            selection: $settingsDetent
        )
        .onChange(of: settingsDetent) {
            if settingsDetent == .fraction(0.2) {
                detents = [.fraction(0.2)]
            } else {
                detents = [.fraction(0.2), .fraction(0.3)]
            }
        }
        .overlay(
            PrioritySelectionView(showPriorityList: $showPriorityList, selectedPriority: $selectedPriority), alignment: .topLeading
        )
        .overlay(
            LabelSelectionOverlayView(showLabelList: $showLabelList, selectedLabel: $selectedLabel), alignment: .topTrailing
        )
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheetContentView(dateDue: $dateDue, showingDatePicker: $showingDatePicker, selectedRange: $selectedRange)
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerSheetContentView(showingLocationPicker: $showingLocationPicker, selectedLocation: $selectedLocation)
        }
        .sheet(isPresented: $showingAddSubTaskView) {
            if let _ = task {
                AddSubtaskView(isVisible: $showingAddSubTaskView, selectedTask: $task)
                    .presentationDetents(
                        detents,
                        selection: $settingsDetent
                    )
            }
        }
        .onTapGesture {
            closeAllOverlays()
        }
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.white)))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isInputActive = true
            }
        }
        .shadow(radius: 1)
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }

    private func loadInitialData() {
        if let task = task {
            taskName = task.title ?? ""
            taskDescription = task.taskDescription ?? ""
            dateDue = task.dateDue
            if let priorityLevel = Constants.priorities.first(where: { $0.level == Int(task.priority) }) {
                selectedPriority = priorityLevel
            }
            if let labelName = task.taskLabel, let label = Constants.labels.first(where: { $0.name == labelName }) {
                selectedLabel = label
            }
            selectedLocation = CLLocationCoordinate2D(latitude: task.latitude, longitude: task.longitude)
        }
        if let subtasksSet = task?.subtasks as? Set<ProjectSubtask> {
            taskSubtasks = subtasksSet
        }
    }

    private func closeAllOverlays() {
        showPriorityList = false
        showLabelList = false
        showingDatePicker = false
        showingLocationPicker = false
    }
    
    private let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private func toggleAddSubTask() {
        showingAddSubTaskView.toggle()
        settingsDetent = settingsDetent == .fraction(0.2) ? .fraction(0.3) : .fraction(0.3)
    }

    private func addTask() {
        if taskName.isEmpty {
            return
        }
        let taskToSave: ProjectTask
        if let existingTask = task {
            taskToSave = existingTask
        } else {
            taskToSave = ProjectTask(context: viewContext)
            taskToSave.dateCreated = Date()
            taskToSave.isCompleted = false
        }
        
        taskToSave.title = taskName
        taskToSave.taskDescription = taskDescription
        taskToSave.dateDue = dateDue
        taskToSave.dateUpdated = Date()
        taskToSave.priority = Int64(selectedPriority?.level ?? 3)
        taskToSave.taskLabel = selectedLabel?.name
        taskToSave.latitude = selectedLocation?.latitude ?? 0
        taskToSave.longitude = selectedLocation?.longitude ?? 0
        if let subtasksSet = taskSubtasks as NSSet? {
            taskToSave.subtasks = subtasksSet
        }

        if let existingProject = selectedProject {
            taskToSave.project = existingProject
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        dismissSheet()
    }

    private func dismissSheet() {
        isVisible = false
        isInputActive = false
    }
}
