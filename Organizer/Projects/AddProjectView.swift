//
//  ProjectCreationModal.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/30/24.
//

import SwiftUI


struct AddProjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isVisible: Bool
    @FocusState private var isInputActive: Bool
    
    @State private var projectName: String = ""
    @State private var projectDescription: String = ""
    @State private var dateDue: Date? = Date()
    @State private var categories: [String] = []
    @State private var selectedCategory: String?
    @State private var keyboardHeight: CGFloat = 0
    @State private var selectedPriority: Priority? = nil
    @State private var showPriorityList = false
    @State private var attemptToSubmit: Bool = false
    @State private var showError: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                NewProjectTitleAndDescriptionView(
                    projectName: $projectName,
                    projectDescription: $projectDescription,
                    isInputActive: _isInputActive,
                    showError: $showError
                )
                Spacer()
                NewProjectAddProjectButtonView(
                    action: addProject,
                    isEnabled: !projectName.isEmpty
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

    private func addProject() {
        if projectName.isEmpty {
            return
        }
        let newProject = Project(context: viewContext)
        newProject.title = projectName
        newProject.projectDescription = projectDescription
        newProject.dateDue = dateDue
        newProject.dateCreated = Date()
        newProject.priority = Int64(selectedPriority?.level ?? 3)
        newProject.isCompleted = false

        do {
            try viewContext.save()
            print("Project saved successfully")
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
