//
//  TaskView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/21/24.
//
import SwiftUI


struct TaskRowView: View {
    @ObservedObject var task: ProjectTask
    @Environment(\.managedObjectContext) var viewContext
    @State private var settingsDetent = PresentationDetent.fraction(0.2)
    @State private var isMarkedComplete = false
    @State private var address: String = "Loading address..."
    @State private var isShowingDetails = false
    
    var body: some View {
        HStack {
            Image(systemName: isMarkedComplete ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMarkedComplete ? .green : .gray)
                .onTapGesture {
                    toggleTaskCompletion()
                }
                .animation(.easeInOut, value: isMarkedComplete)
            VStack(alignment: .leading) {
                Text(task.title ?? "Untitled Task")
                    .strikethrough(task.isCompleted, color: .gray)
                    .foregroundColor(task.isCompleted ? .gray : .black)
                Text("Due: \(task.dateDue ?? Date(), formatter: taskFormatter)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Location: \(address)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .onAppear {
                reverseGeocode(latitude: task.latitude, longitude: task.longitude) { addressString in
                    self.address = addressString
                }
            }
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text("Priority: ")
                        .foregroundColor(.black)
                    Text(getPriorityLevel(fromLevel: task.priority))
                        .foregroundColor(priorityColor(for: task.priority))
                }
                .font(.caption)
                HStack {
                    Text("Label: ")
                        .foregroundColor(.black)
                    Text(getTaskLabel(fromLabel: task.taskLabel ?? "Misc"))
                        .foregroundColor(labelColor(for: task.taskLabel))
                }
                .font(.caption)
            }
        }
        .opacity(isMarkedComplete ? 0 : 1)
        .offset(CGSize(width: 0, height: isMarkedComplete ? -10: 0))
        .contentShape(Rectangle())
        .onDisappear {
            if isMarkedComplete {
                task.isCompleted = true
                saveContext()
            }
        }
        .onTapGesture {
            self.isShowingDetails = true
        }
        .sheet(isPresented: $isShowingDetails) {
            AddTaskView(isVisible: $isShowingDetails, task: task)
                .presentationDetents(
                    [.fraction(0.2)],
                    selection: $settingsDetent
                 )
        }
    }
    
    private func toggleTaskCompletion() {
        withAnimation {
            isMarkedComplete = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                task.isCompleted = true
            }
            saveContext()
        }
    }
    
    private func getPriorityLevel(fromLevel level: Int64) -> String {
        return Constants.priorities.first { $0.level == Int(level) }?.name ?? "Medium"
    }
    
    private func getTaskLabel(fromLabel taskLabel: String) -> String {
        return Constants.labels.first { $0.name == taskLabel }?.name ?? "Misc"
    }

    private func saveContext() {
        try? task.managedObjectContext?.save()
    }
    
    private func priorityColor(for priority: Int64) -> Color {
        return Constants.priorities.first { $0.level == Int(priority) }?.color ?? .black
    }
    
    private func labelColor(for taskLabel: String?) -> Color {
        return Constants.labels.first { $0.name == taskLabel }?.color ?? .black
    }
}

private let taskFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
