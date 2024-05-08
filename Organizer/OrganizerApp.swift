//
//  OrganizerApp.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/20/24.
//

import SwiftUI

@main
struct OrganizerApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Call the method to set up initial data
        persistenceController.setupInitialData()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
