//
//  ContentView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/20/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var settingsDetent = PresentationDetent.fraction(0.2)
    @State private var selectedTab: Int = 0
    @State private var isShowingAddProject = false
    @State private var isShowingAddTask = false
    @State private var newProjectName = ""
    @State private var newTaskName = ""
    @State private var showingNewTaskSheet = false
    @State private var showingNewTaskInProjectSheet = false
    @State private var showingNewProjectSheet = false
    @State private var selectedProject: Project? = nil
    @FocusState private var isInputActive: Bool
    
    var projectTasksFetchRequest: FetchRequest<ProjectTask> {
        FetchRequest<ProjectTask>(
            entity: ProjectTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ProjectTask.dateDue, ascending: true)],
            predicate: NSPredicate(format: "isCompleted == %@", NSNumber(value: false))
        )
    }
    var projectFetchRequest: FetchRequest<Project> {
        FetchRequest<Project>(
            entity: Project.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Project.dateDue, ascending: true)]
        )
    }

    var projects: FetchedResults<Project> { projectFetchRequest.wrappedValue }
    var projectTasks: FetchedResults<ProjectTask> { projectTasksFetchRequest.wrappedValue }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    TabView(selection: $selectedTab) {
                        TodayView()
                            .tabItem {
                                VStack {
                                    CalendarIconView(active: selectedTab == 0 ? true : false)
                                    Text("Today")
                                }
                            }
                            .tag(0)
                        ProjectsListView(selectedProject: $selectedProject)
                            .tabItem {
                                Label(Constants.Titles.projectsTitle, systemImage: "folder")
                            }
                            .tag(1)
                        TasksListView()
                            .tabItem {
                                Label(Constants.Titles.tasksTitle, systemImage: "list.bullet")
                            }
                            .tag(2)
                    }
                }
                if showingNewTaskSheet {
                    Color.gray.opacity(0.5)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.7)) {
                                isInputActive = false
                                showingNewTaskSheet = false
                            }
                        }
                }
                
                if showingNewProjectSheet {
                    Color.gray.opacity(0.5)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.7)) {
                                isInputActive = false
                                showingNewProjectSheet = false
                            }
                        }
                }

                FloatingActionButtonsView(
                    onAddTask: {
                        withAnimation(.easeInOut(duration: 0.7)) {
                            if selectedTab == 1 {
                                if let _ = selectedProject {
                                    showingNewTaskInProjectSheet = true
                                } else {
                                    showingNewProjectSheet = true
                                }
                            } else {
                                showingNewTaskSheet = true
                            }
                        }
                    }
                )
                .padding(.bottom, 75)
            }
            .sheet(isPresented: $showingNewTaskSheet) {
                AddTaskNoProjectView(isVisible: $showingNewTaskSheet)
                    .focused($isInputActive)
                    .presentationDetents(
                        [.fraction(0.2)],
                        selection: $settingsDetent
                     )
            }
            .sheet(isPresented: $showingNewProjectSheet) {
                AddProjectView(isVisible: $showingNewProjectSheet)
                    .focused($isInputActive)
                    .presentationDetents(
                        [.fraction(0.2)],
                        selection: $settingsDetent
                     )
            }
            .sheet(isPresented: $showingNewTaskInProjectSheet) {
                AddTaskInProjectView(isVisible: $showingNewTaskInProjectSheet, selectedProject: $selectedProject)
                    .focused($isInputActive)
                    .presentationDetents(
                        [.fraction(0.2)],
                        selection: $settingsDetent
                     )
            }
        }
    }
    
    private func titleForTab(_ tab: Int) -> String {
        switch tab {
        case 0:
            return Constants.Titles.todayTitle
        case 1:
            return Constants.Titles.projectsTitle
        case 2:
            return Constants.Titles.tasksTitle
        default:
            return Constants.Titles.appName
        }
    }
}

struct FloatingActionButtonsView: View {
    var onAddTask: () -> Void

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                addTaskFloatingActionButton(onAddTask: onAddTask)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private func addTaskFloatingActionButton(onAddTask: @escaping () -> Void) -> some View {
        Button(action: onAddTask) {
            Image(systemName: "plus")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(16)
                .foregroundColor(.white)
                .background(Circle().fill(Color.blue))
                .shadow(radius: 4)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.shared
        ContentView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}
