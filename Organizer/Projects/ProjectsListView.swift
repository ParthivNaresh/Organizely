//
//  ProjectsListView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 5/3/24.
//

import SwiftUI
import CoreData


struct ProjectsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Project.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)])
    var projects: FetchedResults<Project>

    var body: some View {
        NavigationView {
            List {
                Text("Projects")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                ForEach(projects, id: \.self) { project in
                    NavigationLink(destination: ProjectTasksListView(project: project)) {
                        ProjectRowView(project: project)
                    }
                }
            }
        }
    }
}
