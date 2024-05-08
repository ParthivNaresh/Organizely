//
//  AddTaskToProjectView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 5/7/24.
//

import SwiftUI
import MapKit
import MijickCalendarView


struct AddTaskInProjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isVisible: Bool
    @Binding var selectedProject: Project?
    @FocusState private var isInputActive: Bool
    
    @State private var taskName: String = ""
    @State private var taskDescription: String = ""
    @State private var dateDue: Date? = Date()
    @State private var categories: [String] = []
    @State private var selectedCategory: String?
    @State private var keyboardHeight: CGFloat = 0
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
    
    var body: some View {
        ScrollView {
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
                NewTaskAddTaskButtonView(
                    action: addTask,
                    isEnabled: !taskName.isEmpty
                )
            }
            .overlay(
                Group {
                    if showPriorityList {
                        PrioritySelectionOverlay(showPriorityList: $showPriorityList, selectedPriority: $selectedPriority)
                            .alignmentGuide(.top) { _ in 50 }
                    }
                }, alignment: .topLeading
            )
            .overlay(
                Group {
                    if showLabelList {
                        LabelSelectionOverlay(showLabelList: $showLabelList, selectedLabel: $selectedLabel)
                            .alignmentGuide(.top) { _ in 50 }
                    }
                }, alignment: .topTrailing
            )
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheetView(dateDue: $dateDue, showingDatePicker: $showingDatePicker, selectedRange: $selectedRange)
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerSheetView(showingLocationPicker: $showingLocationPicker, selectedLocation: $selectedLocation)
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
    
    private func addTask() {
        if taskName.isEmpty {
            return
        }
        let taskToSave: ProjectTask
        taskToSave = ProjectTask(context: viewContext)
        taskToSave.dateCreated = Date()
        taskToSave.isCompleted = false
        
        taskToSave.title = taskName
        taskToSave.taskDescription = taskDescription
        taskToSave.dateDue = dateDue
        taskToSave.dateUpdated = Date()
        taskToSave.priority = Int64(selectedPriority?.level ?? 3)
        taskToSave.taskLabel = selectedLabel?.name
        taskToSave.latitude = selectedLocation?.latitude ?? 0
        taskToSave.longitude = selectedLocation?.longitude ?? 0
        taskToSave.project = selectedProject

        do {
            try viewContext.save()
            print("Task saved successfully")
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

