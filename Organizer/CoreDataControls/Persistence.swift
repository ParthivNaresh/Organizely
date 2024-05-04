//
//  Persistence.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/20/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = true) {
        container = NSPersistentContainer(name: "Organizer")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func setupInitialData() {
        let context = container.viewContext

        var projects: [Project] = []
        for _ in 0..<5 {
            let projectEntity = Project(context: context)
            projectEntity.title = "Project \((1...100).randomElement()!)"
            projectEntity.projectDescription = "Project description for this project with extra words \((1...100).randomElement()!)"
            projectEntity.isCompleted = false
            projectEntity.priority = Int64(Constants.priorities.randomElement()?.level ?? 3)
            projectEntity.dateDue = Date().addingTimeInterval(TimeInterval.random(in: 0...64000))
            projects.append(projectEntity)
        }

        // Create tasks and associate them with projects
        for _ in 0..<50 {
            let taskEntity = ProjectTask(context: context)
            taskEntity.title = "Task \((1...100).randomElement()!)"
            taskEntity.taskDescription = "Task description for this project with extra words \((1...100).randomElement()!)"
            taskEntity.isCompleted = Bool.random()
            taskEntity.priority = Int64(Constants.priorities.randomElement()?.level ?? 3)
            taskEntity.taskLabel = Constants.labels.randomElement()?.name
            taskEntity.dateDue = Date().addingTimeInterval(TimeInterval.random(in: 0...64000))
            taskEntity.latitude = Double.random(in: -90...90)
            taskEntity.longitude = Double.random(in: -180...180)

            if let assignedProject = projects.randomElement() {
                taskEntity.project = assignedProject
            }
        }

        saveContext()
    }

    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
