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
    @FetchRequest(
        entity: Project.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)]
    )
    var projects: FetchedResults<Project>
    @Binding var selectedProject: Project?

    var body: some View {
        VStack {
            Text(Constants.Titles.projectsTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
            NavigationView {
                List {
                    ForEach(projects, id: \.self) { project in
                        NavigationLink(destination: ProjectTasksListView(project: project, selectedProject: $selectedProject)) {
                            ProjectRowView(project: project)
                        }
                    }
                }
            }
        }
    }
}
