//
//  AddSubtaskView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 5/13/24.
//

import SwiftUI
import MapKit
import MijickCalendarView

struct AddSubtaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isVisible: Bool
    @FocusState private var isInputActive: Bool
    @Binding var selectedTask: ProjectTask?
    var subtask: ProjectSubtask?
    
    @State private var subtaskName: String = ""
    @State private var subtaskDescription: String = ""
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
    
    init(
        isVisible: Binding<Bool>,
        selectedTask: Binding<ProjectTask?> = .constant(nil),
        subtask: ProjectSubtask? = nil
    ) {
        self._isVisible = isVisible
        self._selectedTask = selectedTask
        self.subtask = subtask
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NewSubtaskTitleAndDescriptionView(
                subtaskName: $subtaskName,
                subtaskDescription: $subtaskDescription,
                isInputActive: _isInputActive,
                showError: $showError
            )
            Spacer()
            SubtaskControlButtonsView(
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
                NewSubtaskSubmitSubtaskButtonView(
                    action: addSubtask,
                    isEnabled: !subtaskName.isEmpty
                )
            }
        }
        .onAppear {
            loadInitialData()
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
    }
    
    private func loadInitialData() {
        if let subtask = subtask {
            subtaskName = subtask.title ?? ""
            subtaskDescription = subtask.subtaskDescription ?? ""
            dateDue = subtask.dateDue
            if let priorityLevel = Constants.priorities.first(where: { $0.level == Int(subtask.priority) }) {
                selectedPriority = priorityLevel
            }
            if let labelName = subtask.taskLabel, let label = Constants.labels.first(where: { $0.name == labelName }) {
                selectedLabel = label
            }
            selectedLocation = CLLocationCoordinate2D(latitude: subtask.latitude, longitude: subtask.longitude)
        }
    }

    private func addSubtask() {
        if subtaskName.isEmpty {
            return
        }
        let subtaskToSave: ProjectSubtask
        if let existingSubtask = subtask {
            subtaskToSave = existingSubtask
        } else {
            subtaskToSave = ProjectSubtask(context: viewContext)
            subtaskToSave.dateCreated = Date()
            subtaskToSave.isCompleted = false
        }
        
        subtaskToSave.title = subtaskName
        subtaskToSave.subtaskDescription = subtaskDescription
        subtaskToSave.dateDue = dateDue
        subtaskToSave.dateUpdated = Date()
        subtaskToSave.priority = Int64(selectedPriority?.level ?? 3)
        subtaskToSave.taskLabel = selectedLabel?.name
        subtaskToSave.latitude = selectedLocation?.latitude ?? 0
        subtaskToSave.longitude = selectedLocation?.longitude ?? 0

        if let existingTask = selectedTask {
            subtaskToSave.task = existingTask
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
